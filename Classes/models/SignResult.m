//
//  SignResult.m
//  Neonan
//
//  Created by capricorn on 12-11-2.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "SignResult.h"

@implementation SignResult

+ (id<Jsonable>)parse:(NSDictionary *)JSON {
    DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass:self];
    return [parser parseDictionary:JSON];
}

@end
