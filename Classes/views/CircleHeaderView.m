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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.carousel = [[iCarousel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.carousel.scrollEnabled = NO;
        self.carousel.dataSource = self;
        self.carousel.delegate = self;
        [self addSubview:self.carousel];
        
        UIPanGestureRecognizer *recognizer = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)] autorelease];
        [self addGestureRecognizer:recognizer];
    }
    return self;
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
    return 10;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    UILabel *label;
    if (!view) {
        label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width / 4, self.frame.size.height)] autorelease];
        label.textAlignment = UITextAlignmentCenter;
    } else {
        label = (UILabel *)view;
    }
    
    label.text = [NSString stringWithFormat:@"title%u", index];
    
    return label;
}

#pragma mark - iCarouselDelegate methods

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
