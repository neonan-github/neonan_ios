//
//  NearWorksModel.m
//  Neonan
//
//  Created by capricorn on 12-11-23.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "NearWorksModel.h"

@implementation NearItem
@synthesize contentId, contentType, offset;

@end

@implementation NearWorksModel
@synthesize items;

+ (id<Jsonable>)parse:(NSDictionary *)JSON {
    DCParserConfiguration *config = [DCParserConfiguration configuration];
    
    DCObjectMapping *listMapping = [DCObjectMapping mapKeyPath:@"list" toAttribute:@"items" onClass:self];
    [config addArrayMapper:[DCArrayMapping mapperForClass:[NearItem class] onMapping:listMapping]];
    
    DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass:self andConfiguration:config];
    return [parser parseDictionary:JSON];
}

@end
