//
//  NearTopicDetailsModel.m
//  Neonan
//
//  Created by Wu Yunpeng on 13-2-3.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "NearTopicDetailsModel.h"

@implementation NearTopicDetailsModel
@synthesize items;

+ (id<Jsonable>)parse:(NSDictionary *)JSON {
    DCParserConfiguration *config = [DCParserConfiguration configuration];
    
    DCObjectMapping *listMapping = [DCObjectMapping mapKeyPath:@"list" toAttribute:@"items" onClass:self];
    [config addArrayMapper:[DCArrayMapping mapperForClass:[TopicDetailModel class] onMapping:listMapping]];
    
    DCObjectMapping *nameMapping = [DCObjectMapping mapKeyPath:@"name" toAttribute:@"chName" onClass:[TopicDetailModel class]];
    [config addObjectMapping:nameMapping];
    
    DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass:self andConfiguration:config];
    return [parser parseDictionary:JSON];
}

@end
