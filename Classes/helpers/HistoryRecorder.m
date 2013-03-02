//
//  HistoryRecorder.m
//  Neonan
//
//  Created by capricorn on 13-3-2.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "HistoryRecorder.h"
#import "DBHelper.h"

@implementation Record


@end

static NSString *const kDBName = @"history.db";
static NSString *const kTableName = @"history";
static NSString *const kIDKey = @"contentId";
static NSString *const kTypeKey = @"contentType";

@interface HistoryRecorder ()

@property (nonatomic, strong) DBHelper *dbHelper;

@end

@implementation HistoryRecorder

+ (HistoryRecorder *)sharedRecorder {
    static HistoryRecorder *_sharedRecorder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedRecorder = [[HistoryRecorder alloc] init];
    });
    
    return _sharedRecorder;
}

- (DBHelper *)dbHelper {
    if (!_dbHelper) {
        _dbHelper = [[DBHelper alloc] initWithDBName:kDBName];
    }
    
    return _dbHelper;
}

- (BOOL)isRecorded:(Record *)record {
    FMDatabase *db = self.dbHelper.db;
    if (![db open]) {
        return NO;
    }
    
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where content_id = '%@' and content_type = '%@'",
                     kTableName, record.contentId, record.contentType];
    FMResultSet *rs = [db executeQuery:sql];
    BOOL ret = NO;
    if ([rs next]) {
        ret = YES;
    }
    [rs close];
    [db close];
    
    DLog(@"sql:%@ %d", sql, ret);
    
    return ret;
}

- (void)saveRecord:(Record *)record {
    FMDatabase *db = self.dbHelper.db;
    if (![db open]) {
        return;
    }
    
    [db executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (content_id TEXT NOT NULL, content_type TEXT NOT NULL, PRIMARY KEY (content_id, content_type))", kTableName]];
    [db executeUpdate:[NSString stringWithFormat:@"insert into %@ (content_id, content_type) values('%@', '%@')",
                       kTableName, record.contentId, record.contentType]];
    [db close];
}

@end
