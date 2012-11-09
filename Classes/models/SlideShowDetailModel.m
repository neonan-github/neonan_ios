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
    return [NSArray arrayWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", nil];
}

@end
