//
//  SlideShowView.m
//  Neonan
//
//  Created by capricorn on 12-10-12.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "SlideShowView.h"

@implementation SlideShowView

- (id)initWithFrame:(NSRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        iCarousel *carousel = self.carousel = [[iCarousel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        carousel.decelerationRate = 0.0f;// carousel stops immediately when released
        carousel.ignorePerpendicularSwipes = YES;
//        self.carousel.scrollToItemBoundary = YES;
        carousel.stopAtItemBoundary = YES;
        carousel.bounces = NO;
        carousel.clipsToBounds = YES;
        carousel.dataSource = self;
        carousel.delegate = self;
        [self addSubview:carousel];
    }
    return self;
}

- (void)reloadData {
    [self.carousel reloadData];
}

- (void)update
{
//    const float pageWidth = self.frame.size.width;
//    CGPoint pt = _scrollView.contentOffset;
//    float x;
//    if(self.currentPageIndex == self.pageCount - 1){
//        x = 0;
//    } else {
//        x = pt.x + pageWidth;
//    }
//    
//    [_scrollView scrollRectToVisible:CGRectMake(x, 0, pageWidth, self.frame.size.height) animated:YES];
    NSInteger index = (_carousel.currentItemIndex == _carousel.numberOfItems - 1) ? 0
    : (_carousel.currentItemIndex + 1);
    [_carousel scrollToItemAtIndex:index animated:YES];
}

- (void)startAutoScroll:(double)interval {
    self.slideInterval = interval;
    if (!_slideTimer || _slideTimer.timeInterval != interval) {
        [self stopAutoScroll];
        
        if (interval > 0) {
            self.slideTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                               target:self
                                                             selector:@selector(update)
                                                             userInfo:nil
                                                              repeats:YES];
        }
    }
}

- (void)stopAutoScroll {
    [self.slideTimer invalidate];
    self.slideTimer = nil;
}

- (void)dealloc {
    [self stopAutoScroll];
    self.carousel = nil;
    self.dataSource = nil;
    self.delegate = nil;
}

#pragma mark - iCarouselDataSource methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return [self.dataSource numberOfItemsInSlideShowView:self];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    UIView *cell = [self.dataSource slideShowView:self viewForItemAtIndex:index reusingView:view];
    cell.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    return cell;
}

#pragma mark - iCarouselDelegate methods

- (void)carouselWillBeginDecelerating:(iCarousel *)carousel {
    [self stopAutoScroll];
}

- (void)carouselDidEndDecelerating:(iCarousel *)carousel {
    NSLog(@"didEndDecelerating");
    [self startAutoScroll:self.slideInterval];
}

- (void)carouselWillBeginDragging:(iCarousel *)carousel {
   [self stopAutoScroll]; 
}

- (void)carouselDidEndDragging:(iCarousel *)carousel willDecelerate:(BOOL)decelerate {
    NSLog(@"didEndDragging decelerate:%@ offset:%f itemWidth:%f", (decelerate ? @"y" : @"n"), self.carousel.scrollOffset, self.carousel.itemWidth);
    if (!decelerate) {
        [self startAutoScroll:self.slideInterval];
    } 
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel {
    if (self.delegate) {
        [self.delegate slideShowViewItemIndexDidChange:self];
    }
}

- (BOOL)carousel:(iCarousel *)carousel shouldSelectItemAtIndex:(NSInteger)index {
    return NO;
}

- (CGFloat)carousel:(iCarousel *)_carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            return YES;
        }
        case iCarouselOptionSpacing:
        {
            //add a bit of spacing between the item views
            return value;
        }
        default:
        {
            return value;
        }
    }
}

@end
