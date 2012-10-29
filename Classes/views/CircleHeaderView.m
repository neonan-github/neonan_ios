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
        UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        backgroundView.image = [UIImage imageFromFile:@"bg_header_view.png"];
        [self addSubview:backgroundView];
        self.backgroundColor = [UIColor blackColor];
        
        iCarousel *carousel = self.carousel = [[iCarousel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        carousel.scrollEnabled = NO;
        carousel.dataSource = self;
        carousel.delegate = self;
        [self addSubview:carousel];
        
        UIImage *indicatorImg = [UIImage imageFromFile:@"img_header_indicator.png"];
        UIImageView *indicatorView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - indicatorImg.size.width) / 2, (frame.size.height - indicatorImg.size.height) / 2, indicatorImg.size.width, indicatorImg.size.height)];
        indicatorView.image = indicatorImg;
        [self addSubview:indicatorView];
        
        UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [self addGestureRecognizer:recognizer];
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
        label.textColor = [UIColor whiteColor];
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

- (CGFloat)carouselItemWidth:(iCarousel *)carousel {
    UILabel *currentLabel = (UILabel *)_carousel.currentItemView;
    currentLabel.font = [UIFont systemFontOfSize:14];
    
    NSArray *visibleLables = _carousel.visibleItemViews;
    for (UILabel *label in visibleLables) {
        if (label != currentLabel) {
            label.font = [UIFont systemFontOfSize:10];
        }
    }
    
    return self.frame.size.width / 4;
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
