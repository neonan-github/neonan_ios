//
//  CommenListModel.m
//  Neonan
//
//  Created by capricorn on 12-11-9.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "CommonListModel.h"

@implementation CommonItem
@synthesize thumbUrl, contentType, title, itemId, dateMillis;

- (NSString *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    return [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:([self.dateMillis longLongValue] / 1000)]];
}

@end

@implementation CommonListModel
@synthesize totalCount, items;

+ (id<Jsonable>)parse:(NSDictionary *)JSON {
    DCParserConfiguration *config = [DCParserConfiguration configuration];
    
    DCObjectMapping *listMapping = [DCObjectMapping mapKeyPath:@"list" toAttribute:@"items" onClass:[CommonListModel class]];
    [config addArrayMapper:[DCArrayMapping mapperForClass:[CommonItem class] onMapping:listMapping]];
    
    DCObjectMapping *totalMapping = [DCObjectMapping mapKeyPath:@"total" toAttribute:@"totalCount" onClass:[CommonListModel class]];
    [config addObjectMapping:totalMapping];
    
    DCObjectMapping *urlMapping = [DCObjectMapping mapKeyPath:@"url" toAttribute:@"thumbUrl" onClass:[CommonItem class]];
    [config addObjectMapping:urlMapping];
    
    DCObjectMapping *idMapping = [DCObjectMapping mapKeyPath:@"content_id" toAttribute:@"itemId" onClass:[CommonItem class]];
    [config addObjectMapping:idMapping];
    idMapping = [DCObjectMapping mapKeyPath:@"video_url" toAttribute:@"itemId" onClass:[CommonItem class]];
    [config addObjectMapping:idMapping];
    
    DCObjectMapping *dateMapping = [DCObjectMapping mapKeyPath:@"date" toAttribute:@"dateMillis" onClass:[CommonItem class]];
    [config addObjectMapping:dateMapping];
    
    DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass:self andConfiguration:config];
    return [parser parseDictionary:JSON];
}

- (void)appendMoreData:(CommonListModel *)data {
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
