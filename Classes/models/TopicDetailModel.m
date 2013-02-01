//
//  TopicDetailModel.m
//  Neonan
//
//  Created by capricorn on 13-2-1.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "TopicDetailModel.h"

@implementation TopicDetailModel

+ (id<Jsonable>)parse:(NSDictionary *)JSON {
    DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass:self];
    return [parser parseDictionary:JSON];
}

@end
