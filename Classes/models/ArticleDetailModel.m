//
//  ArticleDetailModel.m
//  Neonan
//
//  Created by capricorn on 12-11-9.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "ArticleDetailModel.h"

@implementation ArticleDetailModel

+ (id<Jsonable>)parse:(NSDictionary *)JSON {
    DCParserConfiguration *config = [DCParserConfiguration configuration];
    
    DCObjectMapping *dateMapping = [DCObjectMapping mapKeyPath:@"date" toAttribute:@"dateMillis" onClass:self];
    [config addObjectMapping:dateMapping];
    
    DCObjectMapping *urlMapping = [DCObjectMapping mapKeyPath:@"url" toAttribute:@"shareUrl" onClass:self];
    [config addObjectMapping:urlMapping];
    
    DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass:self andConfiguration:config];
    return [parser parseDictionary:JSON];
}

- (NSString *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    return [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:([_dateMillis longLongValue] / 1000)]];
}

@end
