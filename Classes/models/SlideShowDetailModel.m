//
//  SlideShowDetailModel.m
//  Neonan
//
//  Created by capricorn on 12-11-9.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "SlideShowDetailModel.h"

@implementation SlideShowDetailModel
@synthesize title, descriptions, shareUrl, imgUrls, brief;

+ (id<Jsonable>)parse:(NSDictionary *)JSON {
    DCParserConfiguration *config = [DCParserConfiguration configuration];
    
    DCObjectMapping *listMapping = [DCObjectMapping mapKeyPath:@"list" toAttribute:@"imgUrls" onClass:self];
    [config addArrayMapper:[DCArrayMapping mapperForClass:[NSString class] onMapping:listMapping]];
    
    DCObjectMapping *urlMapping = [DCObjectMapping mapKeyPath:@"url" toAttribute:@"shareUrl" onClass:self];
    [config addObjectMapping:urlMapping];
    
//    DCObjectMapping *briefMapping = [DCObjectMapping mapKeyPath:@"brief" toAttribute:@"descriptions" onClass:self];
//    [config addArrayMapper:[DCArrayMapping mapperForClass:[NSString class] onMapping:briefMapping]];
    
    DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass:self andConfiguration:config];
    return [parser parseDictionary:JSON];
}

- (NSArray *)descriptions {
    return [NSArray arrayWithObjects:@"的会计法扩大经费可等级分肯定会计法卡山东和福建卡警方可萨芬将会计法看垃圾房卡顿附近开始打击法扩大经费可阿萨德警方萨肯定飞机开始", nil];
}

@end
