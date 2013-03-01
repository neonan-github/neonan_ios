//
//  LoginResult.m
//  HaHa
//
//  Created by capricorn on 12-12-19.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "LoginResult.h"

@implementation LoginResult

+ (id<Jsonable>)parse:(NSDictionary *)JSON {
    DCParserConfiguration *config = [DCParserConfiguration configuration];
    
    DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass:self andConfiguration:config];
    return [parser parseDictionary:JSON];
}

@end
