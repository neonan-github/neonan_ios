//
//  CircleHeaderView.h
//  Neonan
//
//  Created by capricorn on 12-10-16.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iCarousel.h>

@protocol CircleHeaderViewDataSource;

@interface CircleHeaderView : UIView <iCarouselDataSource, iCarouselDelegate>
@property (nonatomic, retain) iCarousel *carousel;

@property (nonatomic, copy) NSArray *titles; // used if dataSource is nil 
@property (nonatomic, assign) id<CircleHeaderViewDataSource> dataSource;

- (void)reloadData;

@end

@protocol CircleHeaderViewDataSource <NSObject>

@end
