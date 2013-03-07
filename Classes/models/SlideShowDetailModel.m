//
//  SlideShowDetailModel.m
//  Neonan
//
//  Created by capricorn on 12-11-9.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "SlideShowDetailModel.h"

@interface SlideShowDetailModel ()

@property (strong, nonatomic) NSString *brief;

@end

@implementation SlideShowDetailModel
//@synthesize title, descriptions, shareUrl, imgUrls, brief, voted;

+ (id<Jsonable>)parse:(NSDictionary *)JSON {
    DCParserConfiguration *config = [DCParserConfiguration configuration];
    
    DCObjectMapping *listMapping = [DCObjectMapping mapKeyPath:@"list" toAttribute:@"imgUrls" onClass:self];
    [config addArrayMapper:[DCArrayMapping mapperForClass:[NSString class] onMapping:listMapping]];
    
    DCObjectMapping *urlMapping = [DCObjectMapping mapKeyPath:@"url" toAttribute:@"shareUrl" onClass:self];
    [config addObjectMapping:urlMapping];
    
    DCObjectMapping *briefsMapping = [DCObjectMapping mapKeyPath:@"briefs" toAttribute:@"descriptions" onClass:self];
    [config addArrayMapper:[DCArrayMapping mapperForClass:[NSString class] onMapping:briefsMapping]];
    
    DCObjectMapping *briefMapping = [DCObjectMapping mapKeyPath:@"breif" toAttribute:@"brief" onClass:self];
    [config addArrayMapper:[DCArrayMapping mapperForClass:[NSString class] onMapping:briefMapping]];
    
    DCObjectMapping *votedMapping = [DCObjectMapping mapKeyPath:@"has_vote" toAttribute:@"voted" onClass:self];
    [config addObjectMapping:votedMapping];
    
    DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass:self andConfiguration:config];
    return [parser parseDictionary:JSON];
}

- (NSArray *)descriptions {
    if (_descriptions) {
        return _descriptions;
    }
    
    return [NSArray arrayWithObject:_brief];
}

- (BOOL)voted {
    return _voted && [[SessionManager sharedManager] canAutoLogin];
}

@end
