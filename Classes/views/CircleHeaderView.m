//
//  CircleHeaderView.m
//  Neonan
//
//  Created by capricorn on 12-10-16.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "CircleHeaderView.h"

static const CGFloat kBottomPadding = 20;// 扩大触摸区域

@interface CircleHeaderView () {
    UIFont *_smallFont, *_bigFont;
}
@property (readonly, nonatomic) UIFont *smallFont;
@property (readonly, nonatomic) UIFont *bigFont;
@end

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
        self.backgroundColor = [UIColor clearColor];
        
        UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - kBottomPadding)];
        backgroundView.image = [UIImage imageFromFile:@"bg_header_view.png"];
        [self addSubview:backgroundView];
        
        iCarousel *carousel = self.carousel = [[iCarousel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        carousel.scrollEnabled = NO;
        carousel.dataSource = self;
        carousel.delegate = self;
        carousel.contentOffset = CGSizeMake(0, -kBottomPadding / 2);
        [self addSubview:carousel];
        
        UIImage *indicatorImg = [UIImage imageFromFile:@"img_header_indicator.png"];
        UIImageView *indicatorView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - indicatorImg.size.width) / 2, (frame.size.height -kBottomPadding - indicatorImg.size.height) / 2, indicatorImg.size.width, indicatorImg.size.height)];
        indicatorView.image = indicatorImg;
        [self addSubview:indicatorView];
        
        UIImage *bottomLineImg = [UIImage imageFromFile:@"img_header_view_bottom_line.png"];
        UIImageView *bottomLineView = [[UIImageView alloc] initWithFrame:CGRectMake(0, frame.size.height - kBottomPadding - bottomLineImg.size.height + 3, frame.size.width, bottomLineImg.size.height)];
        bottomLineView.image = bottomLineImg;
        [self addSubview:bottomLineView];
        
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

- (UIFont *)smallFont {
    if (!_smallFont) {
        _smallFont = [UIFont systemFontOfSize:10];
    }
    
    return _smallFont;
}

- (UIFont *)bigFont {
    if (!_bigFont) {
        _bigFont = [UIFont systemFontOfSize:14];
    }
    
    return _bigFont;
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
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width / 4, self.frame.size.height - kBottomPadding)];
        label.textAlignment = UITextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        label.font = self.smallFont;
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
    currentLabel.font = self.bigFont;
    
    NSArray *visibleLables = _carousel.visibleItemViews;
    for (UILabel *label in visibleLables) {
        if (label != currentLabel) {
            label.font = self.smallFont;
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
