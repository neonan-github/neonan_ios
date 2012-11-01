//
//  ListCellModel.m
//  Neonan
//
//  Created by capricorn on 12-11-1.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "ListCellModel.h"

@implementation ListCellModel

- (id)init {
    if ((self = [super init]))
    {
        self.imgUrl = @"http://neonan.b0.upaiyun.com/uploads/32051a2b-50da-410d-bf3f-d9a10d29357b.jpg";
        self.title = @"卡地亚Tortue万年历腕表在上海国际钟表节 惊艳亮相";
        self.category = @"男士精品";
        self.date = @"2012/05/16 23:12";
    }
    return self;
}

@end
