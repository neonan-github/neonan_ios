//
//  DBHelper.h
//  Neonan
//
//  Created by capricorn on 13-2-1.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FMDatabase.h"

@interface DBHelper : NSObject

@property (nonatomic, readonly) FMDatabase *db;

- (id)initWithDBName:(NSString *)name;

@end
