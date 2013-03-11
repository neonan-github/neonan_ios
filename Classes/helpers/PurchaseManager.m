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

static NSString *const kDBName = @"purchase.db";
static NSString *const kTableName = @"purchase";
static NSString *const kIdKey = @"order_id";
static NSString *const kTokenKey = @"token";
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
    [[NNHttpClient sharedClient] getAtPath:nil parameters:nil responseClass:nil success:^(id<Jsonable> response) {
        if (success) {
            success(nil);
        }
    } failure:^(ResponseError *error) {
        if (failure) {
            failure();
        }
    }];
}

- (void)syncPurchaseInfo:(NSString *)orderId success:(void (^)())success failure:(void (^)())failure {
    [[SessionManager sharedManager] requsetToken:nil success:^(NSString *token) {
        NSString *const timeStamp = @([[NSDate date] timeIntervalSince1970]).stringValue;
        [self savePurchaseInfoToServer:orderId token:token timeStamp:timeStamp success:success failure:failure];
    }];
}

- (void)savePurchaseInfoToLocal:(NSString *)orderId
                          token:(NSString *)token
                      timeStamp:(NSString *)timeStamp
                       notified:(BOOL)notified {
    FMDatabaseQueue *queue = self.dbQueue;
    
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ TEXT PRIMARY KEY, %@ TEXT NOT NULL, %@ TEXT NOT NULL, %@ INTEGER NOT NULL)",
                           kTableName, kIdKey, kTokenKey, kTimeKey, kNotifiedKey]];
        
        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"select * from %@ where %@ = '%@'",
                                            kTableName, kIdKey, orderId]];
        if ([rs next]) {
            if (!notified) {
                [db executeUpdate:[NSString stringWithFormat:@"update %@ set %@ = '%@', %@ = '%@', %@ = %d  where %@ = '%@'", kTableName, kTokenKey, token, kTimeKey, timeStamp,
                                   kNotifiedKey, 0, kIdKey, orderId]];
            } else {
                [db executeUpdate:[NSString stringWithFormat:@"delete from %@ where %@ = '%@'", kTableName, kIdKey, orderId]];
            }
            
        } else {
            [db executeUpdate:[NSString stringWithFormat:@"insert into %@ (%@, %@, %@, %@) values('%@', '%@', '%@', %d)",
                               kTableName, kIdKey, kTokenKey, kTimeKey, kNotifiedKey, orderId, token, timeStamp, notified ? 1 : 0]];
        }
    }];
}

- (void)savePurchaseInfoToServer:(NSString *)orderId
                           token:(NSString *)token
                       timeStamp:(NSString *)timeStamp
                         success:(void (^)())success
                         failure:(void (^)())failure {
    [[NNHttpClient sharedClient] postAtPath:nil
                                parameters:nil
                             responseClass:nil
                                   success:^(id<Jsonable> response) {
                                       [self savePurchaseInfoToLocal:orderId token:token timeStamp:timeStamp notified:YES];
                                       if (success) {
                                           success();
                                       }
                                   }
                                   failure:^(ResponseError *error) {
                                       [self savePurchaseInfoToLocal:orderId token:token timeStamp:timeStamp notified:NO];
                                       if (failure) {
                                           failure();
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
            void (^success)() = ^{
                if (hasNext) {
                    [self commitUnnotifiedInfo:done];
                } else {
                    if (done) {
                        done();
                    }
                }
            };
            
            [self savePurchaseInfoToServer:[rs stringForColumn:kIdKey]
                                     token:[rs stringForColumn:kTokenKey]
                                 timeStamp:[rs stringForColumn:kTimeKey]
                                   success:success
                                   failure:done];
        } else {
            if (done) {
                done();
            }
        }
    }];
}

@end
