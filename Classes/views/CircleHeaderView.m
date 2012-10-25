//
//  CircleHeaderView.m
//  Neonan
//
//  Created by capricorn on 12-10-16.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "CircleHeaderView.h"

@implementation CircleHeaderView
@synthesize carousel = _carousel;
@synthesize titles = _titles;
@synthesize dataSource = _dataSource;
@synthesize currentItemIndex = _currentItemIndex;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        iCarousel *carousel = self.carousel = [[iCarousel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        carousel.scrollEnabled = NO;
        carousel.dataSource = self;
        carousel.delegate = self;
        [self addSubview:carousel];
        
        UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [self addGestureRecognizer:recognizer];
        
        self.backgroundColor = [UIColor darkGrayColor];
    }
    return self;
}

- (void)dealloc {
    self.carousel.dataSource = nil;
    self.carousel.delegate = nil;
    self.carousel = nil;
    
    self.titles = nil;
    
    self.dataSource = nil;
}

- (NSUInteger)currentItemIndex {
    return _carousel.currentItemIndex;
}

- (void)reloadData {
    [self.carousel reloadData];
}

- (void)pan:(UIPanGestureRecognizer *)recognizer {
    CGPoint point = [recognizer velocityInView:self];
    NSLog(@"pan:%f", point.x);
    NSLog(@"currentIndex:%u", self.carousel.currentItemIndex);
    [self.carousel scrollToItemAtIndex:self.carousel.currentItemIndex + (point.x > 0 ? -1 : 1) animated:YES];
}

#pragma mark - iCarouselDataSource methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    if (self.dataSource) {
        return 0; //todo
    }
    
    return self.titles.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    if (self.dataSource) {
        return nil;// todo
    }
    
    UILabel *label;
    if (!view) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width / 4, self.frame.size.height)];
        label.textAlignment = UITextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
    } else {
        label = (UILabel *)view;
    }
    
    label.text = [self.titles objectAtIndex:index];
    
    return label;
}

#pragma mark - iCarouselDelegate methods

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel {
    if (self.delegate) {
        [self.delegate currentItemIndexDidChange:self];
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
