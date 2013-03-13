//
//  VIPManager.m
//  Neonan
//
//  Created by capricorn on 13-3-8.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "PurchaseManager.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

#import "OrderModel.h"
#import "OrderError.h"

static NSString *const kDBName = @"purchase.db";
static NSString *const kTableName = @"purchase";
static NSString *const kIdKey = @"order_id";
static NSString *const kTokenKey = @"token";
static NSString *const kReceiptKey = @"receipt";
static NSString *const kTimeKey = @"time_stamp";
static NSString *const kNotifiedKey = @"notified";

@interface PurchaseManager ()

@property (nonatomic, readonly) FMDatabaseQueue *dbQueue;

@end

@implementation PurchaseManager
@synthesize dbQueue = _dbQueue;

+ (PurchaseManager *)sharedManager {
    static PurchaseManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[PurchaseManager alloc] init];
    });
    
    return _sharedManager;
}

- (FMDatabaseQueue *)dbQueue {
    if (!_dbQueue) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        NSString *dbPath = [documentDirectory stringByAppendingPathComponent:kDBName];
        
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    }
    
    return _dbQueue;
}

- (void)requestOrderId:(NSString *)productId
               success:(void (^)(NSString *orderId))success
               failure:(void (^)())failure {
    [[SessionManager sharedManager] requsetToken:nil success:^(NSString *token) {
        NSDictionary *params = @{@"product_id": productId, @"token": token};
        [[NNHttpClient sharedClient] postAtPath:kPathCreateOrder parameters:params responseClass:[OrderModel class] success:^(id<Jsonable> response) {
            if (success) {
                success([(OrderModel *)response orderId]);
            }
        } failure:^(ResponseError *error) {
            if (failure) {
                failure();
            }
        }];
    }];
}

- (void)syncPurchaseInfo:(NSString *)orderId receipt:(NSString *)purchasedReceipt success:(void (^)())success failure:(void (^)(ResponseError *error))failure {
    [[SessionManager sharedManager] requsetToken:nil success:^(NSString *token) {
        NSString *const timeStamp = @([[NSDate date] timeIntervalSince1970]).stringValue;
        [self savePurchaseInfoToLocal:orderId token:token receipt:purchasedReceipt timeStamp:timeStamp notified:NO];
        [self savePurchaseInfoToServer:orderId token:token receipt:purchasedReceipt timeStamp:timeStamp success:success failure:failure];
    }];
}

- (void)savePurchaseInfoToLocal:(NSString *)orderId
                          token:(NSString *)token
                        receipt:(NSString *)purchasedReceipt 
                      timeStamp:(NSString *)timeStamp
                       notified:(BOOL)notified {
    FMDatabaseQueue *queue = self.dbQueue;
    
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ TEXT PRIMARY KEY, %@ TEXT NOT NULL, %@ TEXT NOT NULL, %@ TEXT NOT NULL, %@ INTEGER NOT NULL)",
                           kTableName, kIdKey, kTokenKey, kReceiptKey, kTimeKey, kNotifiedKey]];
        
        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"select * from %@ where %@ = '%@'",
                                            kTableName, kIdKey, orderId]];
        if ([rs next]) {
            if (!notified) {
                [db executeUpdate:[NSString stringWithFormat:@"update %@ set %@ = %d  where %@ = '%@'", kTableName, kNotifiedKey, 0, kIdKey, orderId]];
            } else {
                [db executeUpdate:[NSString stringWithFormat:@"delete from %@ where %@ = '%@'", kTableName, kIdKey, orderId]];
            }
            
        } else {
            [db executeUpdate:[NSString stringWithFormat:@"insert into %@ (%@, %@, %@, %@, %@) values('%@', '%@', '%@', '%@', %d)",
                               kTableName, kIdKey, kTokenKey, kReceiptKey, kTimeKey, kNotifiedKey, orderId, token, purchasedReceipt, timeStamp, notified ? 1 : 0]];
        }
        
        [rs close];
    }];
}

- (void)savePurchaseInfoToServer:(NSString *)orderId
                           token:(NSString *)token
                         receipt:(NSString *)purchasedReceipt
                       timeStamp:(NSString *)timeStamp
                         success:(void (^)())success
                         failure:(void (^)(ResponseError *error))failure {
    DLog(@"savePurchaseInfoToServer");
    
    [[NNHttpClient sharedClient] postAtPath:kPathFinishOrder
                                 parameters:@{@"order_id": orderId, @"token": token, @"receipt-data": purchasedReceipt}
                             responseClass:[OrderError class]
                                   success:^(id<Jsonable> response) {
                                       OrderError *error = response;
                                       if (error && error.error) {
                                           if (failure) {
                                               failure([[ResponseError alloc] initWithCode:ERROR_BAD_ORDER andMessage:@"验证失败"]);
                                           }
                                           
                                           return;
                                       }
                                       
                                       [self savePurchaseInfoToLocal:orderId token:token receipt:purchasedReceipt timeStamp:timeStamp notified:YES];
                                       if (success) {
                                           success();
                                       }
                                   }
                                   failure:^(ResponseError *error) {
                                       [self savePurchaseInfoToLocal:orderId token:token receipt:purchasedReceipt timeStamp:timeStamp notified:error.errorCode > ERROR_UNPREDEFINED];
                                       if (failure) {
                                           failure(error);
                                       }
                                   }];

}

- (void)commitUnnotifiedInfo:(void (^)())done {
    FMDatabaseQueue *queue = self.dbQueue;
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"select * from %@ where %@ = 0",
                                            kTableName, kNotifiedKey]];
        if ([rs next]) {
            BOOL hasNext = [rs hasAnotherRow];
            DLog(@"hasNext:%d", hasNext);
            
            void (^success)() = ^{
                if (hasNext) {
                    [self commitUnnotifiedInfo:done];
                } else {
                    [rs close];
                    if (done) {
                        done();
                    }
                }
            };
            
            [self savePurchaseInfoToServer:[rs stringForColumn:kIdKey]
                                     token:[rs stringForColumn:kTokenKey]
                                   receipt:[rs stringForColumn:kReceiptKey]
                                 timeStamp:[rs stringForColumn:kTimeKey]
                                   success:success
                                   failure:done];
            [rs close];
        } else {
            [rs close];
            
            if (done) {
                done();
            }
        }
    }];
}

@end
