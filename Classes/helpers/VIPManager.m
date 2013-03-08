//
//  VIPManager.m
//  Neonan
//
//  Created by capricorn on 13-3-8.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "VIPManager.h"
#import "DBHelper.h"

static NSString *const kDBName = @"vip.db";
static NSString *const kTableName = @"purchase";
static NSString *const kIdKey = @"purchase_id"; // 用TimeStamp作为id
static NSString *const kTokenKey = @"token";
static NSString *const kLevelKey = @"vip_level";
static NSString *const kNotifiedKey = @"notified";

@interface VIPManager ()

@property (nonatomic, strong) DBHelper *dbHelper;

@end

@implementation VIPManager

+ (VIPManager *)sharedManager {
    static VIPManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[VIPManager alloc] init];
    });
    
    return _sharedManager;
}

- (DBHelper *)dbHelper {
    if (!_dbHelper) {
        _dbHelper = [[DBHelper alloc] initWithDBName:kDBName];
    }
    
    return _dbHelper;
}

- (void)savePurchaseInfo:(VIPLevel)level {
    [[SessionManager sharedManager] requsetToken:nil success:^(NSString *token) {
        NSString *const timeStamp = @([[NSDate date] timeIntervalSince1970]).stringValue;
//        [self savePurchaseInfoToLocal:level timeStamp:timeStamp];
//        [self savePurchaseInfoToServer:level timeStamp:timeStamp];
    }];
}

- (void)savePurchaseInfoToLocal:(NSString *)token
                      timeStamp:(NSString *)timeStamp
                          level:(VIPLevel)level
                       notified:(BOOL)notified {
    FMDatabase *db = self.dbHelper.db;
    if (![db open]) {
        return;
    }
    
    [db executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ TEXT PRIMARY KEY, %@ TEXT NOT NULL, %@ INTEGER NOT NULL, %@ INTEGER NOT NULL)",
                       kTableName, kIdKey, kTokenKey, kLevelKey, kNotifiedKey]];
    
    FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"select * from %@ where %@ = '%@'",
                                        kTableName, kIdKey, timeStamp]];
    if ([rs next]) {
        [db executeUpdate:[NSString stringWithFormat:@"update %@ set %@ = '%@', %@ = %d, %@ = %d  where %@ = '%@'", kTableName, kTokenKey, token, kLevelKey, level, kNotifiedKey, notified ? 1 : 0, kIdKey, timeStamp]];
    } else {
        [db executeUpdate:[NSString stringWithFormat:@"insert into %@ (%@, %@, %@, %@) values('%@', '%@', %d, %d)",
                           kTableName, kIdKey, kTokenKey, kLevelKey, kNotifiedKey, timeStamp, token, level, notified ? 1 : 0]];
    }
    
    [db close];
}

- (void)savePurchaseInfoToServer:(NSString *)token
                      timeStamp:(NSString *)timeStamp
                          level:(VIPLevel)level {
    #warning TODO: save to server

}

- (void)commitUnNotifiedInfo {
    
}

@end
