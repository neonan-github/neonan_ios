//
//  CommentListModel.m
//  Neonan
//
//  Created by capricorn on 12-11-14.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "CommentListModel.h"

@implementation CommentItem
@synthesize visitor, dateMillis, content;

- (NSString *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    return [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:([self.dateMillis longLongValue] / 1000)]];
}

@end

@implementation CommentListModel
@synthesize totalCount, items;

+ (id<Jsonable>)parse:(NSDictionary *)JSON {
    DCParserConfiguration *config = [DCParserConfiguration configuration];
    
    DCObjectMapping *listMapping = [DCObjectMapping mapKeyPath:@"list" toAttribute:@"items" onClass:self];
    [config addArrayMapper:[DCArrayMapping mapperForClass:[CommentItem class] onMapping:listMapping]];
    
    DCObjectMapping *totalMapping = [DCObjectMapping mapKeyPath:@"total" toAttribute:@"totalCount" onClass:self];
    [config addObjectMapping:totalMapping];
    
    DCObjectMapping *dateMapping = [DCObjectMapping mapKeyPath:@"date" toAttribute:@"dateMillis" onClass:[CommentItem class]];
    [config addObjectMapping:dateMapping];
    
    DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass:self andConfiguration:config];
    return [parser parseDictionary:JSON];
}

- (void)appendMoreData:(CommentListModel *)data {
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
