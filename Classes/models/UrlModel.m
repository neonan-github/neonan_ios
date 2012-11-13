//
//  UrlModel.m
//  Neonan
//
//  Created by capricorn on 12-11-13.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "UrlModel.h"

@implementation UrlModel

+ (id<Jsonable>)parse:(NSDictionary *)JSON {
    DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass:self];
    return [parser parseDictionary:JSON];
}

@end
