//
//  BabyCellModel.h
//  Neonan
//
//  Created by capricorn on 12-11-1.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BabyCellModel : NSObject
@property (copy, nonatomic) NSString *babyImgUrl;
@property (copy, nonatomic) NSString *title;
@property (assign, nonatomic) NSUInteger *score;
@property (copy, nonatomic) NSArray *shotImgUrls;
@property (copy, nonatomic) NSArray *videoUrls;
@end
