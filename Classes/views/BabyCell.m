//
//  BabyCell.m
//  Neonan
//
//  Created by capricorn on 12-10-15.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "BabyCell.h"

static const float kCellMarginLeft = 8;
static const float kCellMarginTop = 8;
static const float kCellMarginBottom = 8;

static const float kThumbnailWidth = 45;
static const float kTextAreaWidth = 60;
static const float kTextAreaMargin = 20;
static const float kLeftPartWidth = 188;

@interface BabyCell ()
@property (nonatomic, unsafe_unretained) UIView *centerDivider;
@property (nonatomic, unsafe_unretained) iCarousel *carousel;
@end

@implementation BabyCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.customBackgroundColor = RGB(26, 26, 26);
        self.customSeparatorColor = RGB(13, 13, 13);
        
        UIImageView *thumbnail = self.thumbnail = [[UIImageView alloc] init];
        
        UILabel *titleLabel = self.titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont systemFontOfSize:16];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        
        UILabel *scoreLabel = self.scoreLabel = [[UILabel alloc] init];
        scoreLabel.font = [UIFont systemFontOfSize:12];
        scoreLabel.textAlignment = NSTextAlignmentCenter;
        scoreLabel.backgroundColor = [UIColor clearColor];
        scoreLabel.textColor = [UIColor whiteColor];
        
        UIButton *voteButton = self.voteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        voteButton.titleLabel.font = [UIFont systemFontOfSize:10];
        [voteButton setTitle:@"点击投票" forState:UIControlStateNormal];
        
        UIButton *arrowView = self.arrowView = [UIButton buttonWithType:UIButtonTypeCustom];
        [arrowView setImage:[UIImage imageNamed:@"icon_right_arrow_white.png"] forState:UIControlStateNormal];
        
        UIView *centerDivider = self.centerDivider = [[UIView alloc] init];
        centerDivider.backgroundColor = [UIColor redColor];
        
        UIButton *playButton = self.playButton = [[UIButton alloc] init];
        
        iCarousel *carousel = self.carousel = [[iCarousel alloc] init];
        carousel.dataSource = self;
        carousel.delegate = self;
        
        [self.contentView addSubview:thumbnail];
        [self.contentView addSubview:titleLabel];
        [self.contentView addSubview:scoreLabel];
        [self.contentView addSubview:voteButton];
        [self.contentView addSubview:arrowView];
        [self.contentView addSubview:centerDivider];
        [self.contentView addSubview:playButton];
        [self.contentView addSubview:carousel];
    }
    return self;
}

- (void)setVideoShots:(NSArray *)videoShots {
    if (_videoShots != videoShots) {
        _videoShots = videoShots;
    }
    
    [self.carousel reloadData];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
//    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    const float cellHeight = self.frame.size.height;
    const float cellWidth = self.frame.size.width;
    const float contentHeight = cellHeight - kCellMarginTop - kCellMarginBottom;
    const float dividerX = kLeftPartWidth;
    
    float x = kCellMarginLeft;
    self.thumbnail.frame = CGRectMake(x, kCellMarginTop, kThumbnailWidth, contentHeight);
    
    x += kThumbnailWidth + kTextAreaMargin;
    self.titleLabel.frame = CGRectMake(kCellMarginLeft + kThumbnailWidth, kCellMarginTop, kTextAreaWidth + kTextAreaMargin * 2, contentHeight / 3);
    self.scoreLabel.frame = CGRectMake(x, kCellMarginTop + contentHeight / 3, kTextAreaWidth, contentHeight / 3);
    self.voteButton.frame = CGRectMake(x, kCellMarginTop + contentHeight * 2 / 3, kTextAreaWidth, contentHeight / 3 - 6);
    self.voteButton.center = CGPointMake(x + kTextAreaWidth / 2, kCellMarginTop + contentHeight * 5 / 6);
    
    self.arrowView.frame = CGRectMake(kLeftPartWidth - 20 - 11, (cellHeight - 12) / 2, 11, 12);
    
    //center divider
    self.centerDivider.frame = CGRectMake(dividerX, kCellMarginTop, 1, contentHeight);
    
    self.carousel.frame = CGRectMake(dividerX + 20, kCellMarginTop, cellWidth - dividerX - 20 * 2, contentHeight);
    self.carousel.clipsToBounds = YES;
}

- (void)dealloc {
    self.thumbnail = nil;
    self.titleLabel = nil;
    self.scoreLabel = nil;
    self.voteButton = nil;
    self.arrowView = nil;
    self.centerDivider = nil;
    self.playButton = nil;
    
    self.carousel.dataSource = nil;
    self.carousel.delegate = nil;
    self.carousel = nil;
    
    self.videoShots = nil;
}

#pragma mark - iCarouselDataSource methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return self.videoShots.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    UIImageView *imageView = nil;
    
    //create new view if no view is available for recycling
    if (view == nil)
    {
        view = imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, carousel.frame.size.width - 20, carousel.frame.size.height)];
    }
    else
    {
        imageView = (UIImageView *) view;
    }
    
    imageView.image = [UIImage imageNamed:[self.videoShots objectAtIndex:index]];
    
    return view;
}

- (CGFloat)carousel:(iCarousel *)_carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            //normally you would hard-code this to YES or NO
            return NO;
        }
        case iCarouselOptionSpacing:
        {
            //add a bit of spacing between the item views
            return value * 1.05f;
        }
        default:
        {
            return value;
        }
    }    
}

@end
