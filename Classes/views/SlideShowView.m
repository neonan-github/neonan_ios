//
//  SlideShowView.m
//  Neonan
//
//  Created by capricorn on 12-10-12.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "SlideShowView.h"

@implementation SlideShowView
@synthesize slideInterval;
@synthesize slideTimer;
@synthesize carousel;
@synthesize dataSource;
@synthesize delegate;

- (id)initWithFrame:(NSRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        self.carousel = [[[iCarousel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)] autorelease];
        self.carousel.decelerationRate = 0.0f;// page scroll
        self.carousel.stopAtItemBoundary = YES;
        self.carousel.bounces = NO;
        self.carousel.clipsToBounds = YES;
        self.carousel.dataSource = self;
        self.carousel.delegate = self;
        [self addSubview:self.carousel];
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
    NSInteger index = (self.carousel.currentItemIndex == self.carousel.numberOfItems - 1) ? 0
    : (self.carousel.currentItemIndex + 1);
    [self.carousel scrollToItemAtIndex:index animated:YES];
}

- (void)startAutoScroll:(double)interval {
    self.slideInterval = interval;
    if (!self.slideTimer || self.slideTimer.timeInterval != interval) {
        [self.slideTimer invalidate];
        self.slideTimer = nil;
    
        self.slideTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                 target:self
                                               selector:@selector(update)
                                               userInfo:nil
                                                repeats:YES];
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
    [super dealloc];
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
    [self startAutoScroll:self.slideInterval];
}

- (void)carouselWillBeginDragging:(iCarousel *)carousel {
   [self stopAutoScroll]; 
}

- (void)carouselDidEndDragging:(iCarousel *)carousel willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self startAutoScroll:self.slideInterval];
    }
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel {
    if (self.delegate) {
        [self.delegate slideShowViewItemIndexDidChange:self];
    }
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
