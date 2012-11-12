//
//  HtmlModel.m
//  Neonan
//
//  Created by capricorn on 12-11-12.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "HtmlModel.h"

@implementation HtmlModel

+ (id<Jsonable>)parse:(NSDictionary *)JSON {
    DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass:self];
    return [parser parseDictionary:JSON];
}

@end
