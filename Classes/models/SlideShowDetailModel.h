//
//  SlideShowDetailModel.h
//  Neonan
//
//  Created by capricorn on 12-11-9.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SlideShowDetailModel : NSObject <Jsonable>
@property (nonatomic, copy) NSString *contentId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray *descriptions;
@property (nonatomic, strong) NSString *shareUrl;
@property (nonatomic, strong) NSArray *imgUrls;
@property (nonatomic, assign) BOOL voted;
@property (assign, nonatomic) NSInteger favStatus;

@property (assign, nonatomic) BOOL favorited;
@end
