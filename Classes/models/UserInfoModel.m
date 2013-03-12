//
//  UserInfoModel.m
//  Bang
//
//  Created by capricorn on 13-1-8.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "UserInfoModel.h"

@implementation UserInfoModel

+ (id<Jsonable>)parse:(NSDictionary *)JSON {
    DCParserConfiguration *config = [DCParserConfiguration configuration];
    
    DCObjectMapping *vipMapping = [DCObjectMapping mapKeyPath:@"is_vip" toAttribute:@"vip" onClass:self];
    [config addObjectMapping:vipMapping];
    
    DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass:self andConfiguration:config];
    return [parser parseDictionary:JSON];
}

@end
