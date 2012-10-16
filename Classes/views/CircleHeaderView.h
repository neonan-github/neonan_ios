//
//  CircleHeaderView.h
//  Neonan
//
//  Created by capricorn on 12-10-16.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iCarousel.h>

@interface CircleHeaderView : UIView <iCarouselDataSource, iCarouselDelegate>
@property (nonatomic, retain) iCarousel *carousel;

- (void)reloadData;

@end
