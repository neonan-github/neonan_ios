//
//  OrderModel.m
//  Neonan
//
//  Created by capricorn on 13-3-11.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "OrderModel.h"

@implementation OrderModel

+ (id<Jsonable>)parse:(NSDictionary *)JSON {
    DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass:self];
    return [parser parseDictionary:JSON];
}

@end
