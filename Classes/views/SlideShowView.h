//
//  SlideShowView.h
//  Neonan
//
//  Created by capricorn on 12-10-12.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <iCarousel.h>

@protocol SlideShowViewDataSource, SlideShowViewDelegate;

@interface SlideShowView : UIView <iCarouselDataSource, iCarouselDelegate>
@property (nonatomic, assign) NSTimeInterval slideInterval;
@property (nonatomic, retain) NSTimer *slideTimer;
@property (nonatomic, retain) iCarousel *carousel;
@property (nonatomic, assign) id<SlideShowViewDataSource> dataSource;
@property (nonatomic, assign) id<SlideShowViewDelegate> delegate;

- (void)reloadData;
- (void)startAutoScroll:(double)interval;
- (void)stopAutoScroll;
@end

@protocol SlideShowViewDataSource <NSObject>

- (NSUInteger)numberOfItemsInSlideShowView:(SlideShowView *)slideShowView;
- (UIView *)slideShowView:(SlideShowView *)slideShowView viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view;

@end

@protocol SlideShowViewDelegate <NSObject>

- (void)slideShowViewItemIndexDidChange:(SlideShowView *)slideShowView;

@end
