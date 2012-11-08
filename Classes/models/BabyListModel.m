//
//  BabyListModel.m
//  Neonan
//
//  Created by capricorn on 12-11-8.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "BabyListModel.h"
#import "VideoModel.h"

@implementation BabyItem
@synthesize contentId, babyName, list, photoUrl, voteNum;

@end

@implementation BabyListModel
@synthesize totalCount, list;

+ (id<Jsonable>)parse:(NSDictionary *)JSON {
    DCParserConfiguration *config = [DCParserConfiguration configuration];
    
    DCArrayMapping *mapper = [DCArrayMapping mapperForClassElements:[BabyItem class] forAttribute:@"list" onClass:[BabyListModel class]];
    [config addArrayMapper:mapper];
    
    mapper = [DCArrayMapping mapperForClassElements:[VideoModel class] forAttribute:@"list" onClass:[BabyItem class]];
    [config addArrayMapper:mapper];
    
    DCObjectMapping *totalMapping = [DCObjectMapping mapKeyPath:@"total" toAttribute:@"totalCount" onClass:[BabyListModel class]];
    [config addObjectMapping:totalMapping];
    
    DCObjectMapping *nameMapping = [DCObjectMapping mapKeyPath:@"name" toAttribute:@"babyName" onClass:[BabyItem class]];
    [config addObjectMapping:nameMapping];
    
    DCObjectMapping *photoMapping = [DCObjectMapping mapKeyPath:@"url" toAttribute:@"photoUrl" onClass:[BabyItem class]];
    [config addObjectMapping:photoMapping];
    
    DCObjectMapping *urlMapping = [DCObjectMapping mapKeyPath:@"url" toAttribute:@"imgUrl" onClass:[VideoModel class]];
    [config addObjectMapping:urlMapping];
    
    DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass:self andConfiguration:config];
    return [parser parseDictionary:JSON];
}

@end
