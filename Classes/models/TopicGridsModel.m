//
//  TopicGridsModel.m
//  Neonan
//
//  Created by capricorn on 13-2-1.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "TopicGridsModel.h"

@implementation TopicItem
@synthesize contentId, imageUrl, name, ranking;

@end

@implementation TopicGridsModel
@synthesize items, totalCount;

+ (id<Jsonable>)parse:(NSDictionary *)JSON {
    DCParserConfiguration *config = [DCParserConfiguration configuration];
    
    DCObjectMapping *listMapping = [DCObjectMapping mapKeyPath:@"list" toAttribute:@"items" onClass:self];
    [config addArrayMapper:[DCArrayMapping mapperForClass:[TopicItem class] onMapping:listMapping]];
    
    DCObjectMapping *totalMapping = [DCObjectMapping mapKeyPath:@"total" toAttribute:@"totalCount" onClass:self];
    [config addObjectMapping:totalMapping];
    
    DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass:self andConfiguration:config];
    return [parser parseDictionary:JSON];
}

- (void)appendMoreData:(TopicGridsModel *)data {
    NSMutableArray *array;
    if ([self.items isKindOfClass:[NSMutableArray class]]) {
        array = (NSMutableArray *)self.items;
    } else {
        array = [NSMutableArray arrayWithArray:self.items];
    }
    
    [array addObjectsFromArray:data.items];
    self.items = array;
}


@end
