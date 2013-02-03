//
//  DBHelper.m
//  Neonan
//
//  Created by capricorn on 13-2-1.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "DBHelper.h"

@interface DBHelper () {
    FMDatabase *_db;
}

@end

@implementation DBHelper

- (id)initWithDBName:(NSString *)name {
    self = [super init];
    if (self) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        NSString *dbPath = [documentDirectory stringByAppendingPathComponent:name];
        NSLog(@"数据库所在路径：%@", dbPath);
        
        _db = [FMDatabase databaseWithPath:dbPath] ;
    }
    
    return self;
}

- (FMDatabase *)db {
    return _db;
}

@end
