//
//  OrderError.m
//  Neonan
//
//  Created by capricorn on 13-3-13.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "OrderError.h"

@implementation OrderError

+ (id<Jsonable>)parse:(NSDictionary *)JSON {
    DCParserConfiguration *config = [DCParserConfiguration configuration];
    
    DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass:self andConfiguration:config];
    return [parser parseDictionary:JSON];
}

@end
