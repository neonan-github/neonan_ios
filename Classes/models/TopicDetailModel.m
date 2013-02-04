//
//  TopicDetailModel.m
//  Neonan
//
//  Created by capricorn on 13-2-1.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "TopicDetailModel.h"

@implementation TopicDetailModel
@synthesize contentId, description, chName, enName, imageUrl;
@synthesize ranking, upCount, downCount;

+ (id<Jsonable>)parse:(NSDictionary *)JSON {
    DCParserConfiguration *config = [DCParserConfiguration configuration];
    
    DCObjectMapping *nameMapping = [DCObjectMapping mapKeyPath:@"name" toAttribute:@"chName" onClass:self];
    [config addObjectMapping:nameMapping];
    
    DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass:self andConfiguration:config];
    return [parser parseDictionary:JSON];
}

@end
