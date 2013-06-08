//
//  CommentListModel.m
//  Neonan
//
//  Created by capricorn on 12-11-14.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "CommentListModel.h"

@implementation CommentItem
@synthesize visitor, dateMillis, content, avatar, level, vip;

- (NSString *)formateDate:(NSDate *)adjustedDate withDifference:(NSInteger)timeDifference {
    if (timeDifference < kMinuteSeconds) {
        return @"刚才";
    }
    
    if (timeDifference < kHourSeconds) {
        return [NSString stringWithFormat:@"%d分钟前", timeDifference / kMinuteSeconds];
    }
    
    if (timeDifference < kDaySeconds) {
        return [NSString stringWithFormat:@"%d小时前", timeDifference / kHourSeconds];
    }
    
    if (timeDifference < 10 * kDaySeconds) {
        return [NSString stringWithFormat:@"%d天前", timeDifference / kDaySeconds];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    return [formatter stringFromDate:adjustedDate];
}

- (NSString *)date {
    NSTimeZone *tz = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    NSInteger seconds = -[tz secondsFromGMT];
    NSDate *adjustedDate = [NSDate dateWithTimeIntervalSince1970:([self.dateMillis longLongValue] / 1000 + seconds)];
    NSInteger timeDifference = [[NSDate date] timeIntervalSinceDate:adjustedDate];
    
    return [self formateDate:adjustedDate withDifference:timeDifference];
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
    
    DCObjectMapping *vipMapping = [DCObjectMapping mapKeyPath:@"is_vip" toAttribute:@"vip" onClass:[CommentItem class]];
    [config addObjectMapping:vipMapping];
    
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
