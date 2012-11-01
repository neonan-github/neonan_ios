//
//  BabyCellModel.m
//  Neonan
//
//  Created by capricorn on 12-11-1.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "BabyCellModel.h"

@implementation BabyCellModel

- (id)init {
    if ((self = [super init]))
    {
        self.babyImgUrl = @"http://neonan.b0.upaiyun.com/uploads/e505a4e5-329a-4efa-909b-993a7c762925.jpg";
        self.title = @"房程程";
        self.score = 1001;
        self.shotImgUrls = [[NSArray alloc] initWithObjects:@"http://neonan.b0.upaiyun.com/uploads/4f90ab23-bb09-4849-89ac-4e4589822651.jpg",
        @"http://neonan.b0.upaiyun.com/uploads/9870cd33-9710-4af8-addb-4922d7f6c9fc.jpg",
        @"http://www.neonan.com/UpLoadFolder/2011-09-19/201109191937175159659.jpg", nil];
    }
    return self;
}

@end
