//
//  MainSlideShowModel.m
//  Neonan
//
//  Created by capricorn on 12-11-8.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "MainSlideShowModel.h"

@implementation MSSItem
@synthesize title, contentId, contentType, imgUrl;
@end

@implementation MainSlideShowModel
@synthesize list;

+ (id<Jsonable>)parse:(NSDictionary *)JSON {
    DCArrayMapping *mapper = [DCArrayMapping mapperForClassElements:[MSSItem class] forAttribute:@"list" onClass:[MainSlideShowModel class]];
    
    DCParserConfiguration *config = [DCParserConfiguration configuration];
    [config addArrayMapper:mapper];
    
//    DCObjectMapping *idMapping = [DCObjectMapping mapKeyPath:@"content_id" toAttribute:@"contentId" onClass:[MSSItem class]];
//    [config addObjectMapping:idMapping];
//    
//    DCObjectMapping *typeMapping = [DCObjectMapping mapKeyPath:@"content_type" toAttribute:@"contentType" onClass:[MSSItem class]];
//    [config addObjectMapping:typeMapping];
//    
    DCObjectMapping *urlMapping = [DCObjectMapping mapKeyPath:@"url" toAttribute:@"imgUrl" onClass:[MSSItem class]];
    [config addObjectMapping:urlMapping];
    
    DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass:[MainSlideShowModel class] andConfiguration:config];
    return [parser parseDictionary:JSON];
}

@end
