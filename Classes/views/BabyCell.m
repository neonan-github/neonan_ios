//
//  BabyCell.m
//  Neonan
//
//  Created by capricorn on 12-10-15.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "BabyCell.h"
#import <UIButton+WebCache.h>

static const float kCellMarginLeft = 10;
static const float kCellMarginTop = 7;
static const float kCellMarginBottom = 7;

static const float kThumbnailWidth = 50;
static const float kTextAreaWidth = 54;
static const float kTextAreaMargin = 10;
static const float kLeftPartWidth = 160;

// 图片长宽比
static const CGFloat kVideoShotRatio = 300.f / 190.f;
static const CGFloat kPhotoRatio = 246.f / 320.f;

static const NSInteger kTagItemImgView = 2000;
static const NSInteger kTagItemPlayButton = 2001;

@interface BabyCell () <SDWebImageManagerDelegate>
@property (nonatomic, unsafe_unretained) UIImageView *centerDivider;
@property (nonatomic, unsafe_unretained) iCarousel *carousel;

- (UIButton *)createItemView:(iCarousel *)carousel;

@end

@implementation BabyCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.customBackgroundColor = DarkThemeColor;
        self.customSeparatorColor = RGB(13, 13, 13);
        self.selectionGradientStartColor = DarkThemeColor;
        self.selectionGradientEndColor = DarkThemeColor;
        
        CGFloat x = kCellMarginLeft;
        CGFloat y = kCellMarginTop;
        UIImageView *thumbnail = self.thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, kThumbnailWidth, 0)];
        
        x += kThumbnailWidth + 8;
        y += 5;
        UILabel *titleLabel = self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, kTextAreaWidth, 12)];
        titleLabel.font = [UIFont boldSystemFontOfSize:12];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        
        y += 12 + 10;
        UIImageView *loveImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 10, 10)];
        loveImgView.image = [UIImage imageNamed:@"icon_love_highlighted.png"];
        
        UILabel *scoreLabel = self.scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(x + 14, y, 40, 10)];
        scoreLabel.font = [UIFont systemFontOfSize:7];
        scoreLabel.backgroundColor = [UIColor clearColor];
        scoreLabel.textColor = [UIColor whiteColor];
        
        UIButton *voteButton = self.voteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        voteButton.frame = CGRectMake(x, 52, kTextAreaWidth, 15);
        voteButton.titleLabel.font = [UIFont systemFontOfSize:8];
        [voteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [voteButton setTitle:@"投她一票" forState:UIControlStateNormal];
        [voteButton setBackgroundImage:[UIImage imageNamed:@"bg_btn_vote.png"] forState:UIControlStateNormal];
//        [voteButton setBackgroundImage:[UIImage imageNamed:@"bg_btn_vote.png"] forState:UIControlStateSelected];
        [voteButton addTarget:self action:@selector(vote) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView *arrowView = self.arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_disclosure_normal.png"] highlightedImage:[UIImage imageNamed:@"icon_disclosure_highlighted.png"]];
        arrowView.frame = CGRectMake(kLeftPartWidth - 3 - 20, 0, 20, 20);
        
        UIImageView *centerDivider = self.centerDivider = [[UIImageView alloc] initWithImage:[UIImage imageFromFile:@"img_cell_divider.png"]];
        centerDivider.frame = CGRectMake(kLeftPartWidth, 0, 1, 80);
        
        iCarousel *carousel = self.carousel = [[iCarousel alloc] initWithFrame:CGRectMake(kLeftPartWidth + 10, kCellMarginTop, 0, 0)];
        carousel.contentOffset = CGSizeMake(-20, 0);
        carousel.clipsToBounds = YES;
        carousel.dataSource = self;
        carousel.delegate = self;
        carousel.bounces = NO;
        carousel.centerItemWhenSelected = NO;
        
        [self.contentView addSubview:thumbnail];
        [self.contentView addSubview:titleLabel];
        [self.contentView addSubview:loveImgView];
        [self.contentView addSubview:scoreLabel];
        [self.contentView addSubview:voteButton];
        [self.contentView addSubview:arrowView];
        [self.contentView addSubview:centerDivider];
        [self.contentView addSubview:carousel];
    }
    return self;
}

- (void)dealloc {
    self.delegate = nil;
    
    self.thumbnail = nil;
    self.titleLabel = nil;
    self.scoreLabel = nil;
    self.voteButton = nil;
    self.arrowView = nil;
    self.centerDivider = nil;
    
    self.carousel.dataSource = nil;
    self.carousel.delegate = nil;
    self.carousel = nil;
    
    self.videoShots = nil;
}

- (void)setVideoShots:(NSArray *)videoShots {
    if (_videoShots != videoShots) {
        _videoShots = videoShots;
    }
    
    [self.carousel reloadData];
}

- (void)setVoted:(BOOL )voted {
    _voted = voted;
    [_voteButton setTitle:(voted ? @"已投票" : @"投她一票") forState:UIControlStateNormal];
    _voteButton.enabled = !voted;
}

- (void)reset {
    [self.carousel scrollToItemAtIndex:0 animated:NO];
}

#pragma mark - Override

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    _voteButton.highlighted = NO;
    
    NSArray *visibleItems = _carousel.visibleItemViews;
    for (UIButton *item in visibleItems) {
        item.highlighted = NO;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    _voteButton.selected = NO;
    // If you don't set highlighted to NO in this method,
    // for some reason it'll be highlighed while the
    // table cell selection animates out
    _voteButton.highlighted = NO;
    NSArray *visibleItems = _carousel.visibleItemViews;
    for (UIButton *item in visibleItems) {
        item.selected = NO;
        item.highlighted = NO;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    const float cellHeight = self.frame.size.height;
    const float cellWidth = self.frame.size.width;
    const float contentHeight = cellHeight - kCellMarginTop - kCellMarginBottom;
    const float dividerX = kLeftPartWidth;
    
    CGRect frame = _thumbnail.frame;
    frame.size.height = contentHeight;
    frame.size.width = contentHeight * kPhotoRatio;
    _thumbnail.frame = frame;
    
    frame = _arrowView.frame;
    frame.origin.y = (cellHeight - 20) / 2;
    _arrowView.frame = frame;
    
    frame = _centerDivider.frame;
    frame.size.height = cellHeight - 5;
    _centerDivider.frame = frame;
    
    frame = _carousel.frame;
    frame.size.width = cellWidth - dividerX - 10;
    frame.size.height = contentHeight;
    _carousel.frame = frame;
}

#pragma mark - iCarouselDataSource methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return self.videoShots.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    //create new view if no view is available for recycling
    if (!view) {
        view = [self createItemView:carousel];
    }
    
    UIButton *itemView = (UIButton *)view;
    view.tag = index;
    
    [itemView setBackgroundImage:[UIImage imageFromFile:@"img_baby_video_place_holder.png"] forState:UIControlStateNormal];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadWithURL:[_videoShots objectAtIndex:index]
                    delegate:self
                     options:0
                     success:^(UIImage *image, BOOL cached)
    {
        [itemView setBackgroundImage:image forState:UIControlStateNormal];
    }
                     failure:nil];
    
    return view;
}

#pragma mark - iCarouselDelegate methods

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
            return value * 1.05;
        }
        default:
        {
            return value;
        }
    }    
}

#pragma mark - Private methods

- (UIButton *)createItemView:(iCarousel *)carousel {
    UIButton *itemView = [UIButton buttonWithType:UIButtonTypeCustom];
    [itemView setImage:[UIImage imageFromFile:@"icon_play_video.png"]  forState:UIControlStateNormal];
    [itemView addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect frame = itemView.frame;
    frame.size.width = carousel.frame.size.height * kVideoShotRatio;
    frame.size.height = carousel.frame.size.height;
    itemView.frame = frame;
    
    return itemView;
}

- (void)vote {
    if (_delegate) {
        NSInteger index = self.tag;
        [_delegate voteBabyAtIndex:index];
    }
}

- (void)playVideo:(UIView *)view {
    if (_delegate) {
        NSInteger index = view.tag;
        [_delegate playVideo:[_videoUrls objectAtIndex:index]];
    }
}

@end
