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

@interface BabyCell ()
@property (nonatomic, unsafe_unretained) UIView *centerDivider;
@property (nonatomic, unsafe_unretained) iCarousel *carousel;
@end

@implementation BabyCell
@synthesize thumbnail = _thumbnail, titleLabel = _titleLabel,
descriptionLabel = _descriptionLabel, dateLabel = _dateLabel;
@synthesize centerDivider = _centerDivider;
@synthesize playButton = _playButton;
@synthesize carousel = _carousel;
@synthesize videoShots = _videoShots;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UIImageView *thumbnail = self.thumbnail = [[UIImageView alloc] init];
        UILabel *titleLabel = self.titleLabel = [[UILabel alloc] init];
        UILabel *descriptionLabel = self.descriptionLabel = [[UILabel alloc] init];
        UILabel *dateLabel = self.dateLabel = [[UILabel alloc] init];
        
        UIView *centerDivider = self.centerDivider = [[UIView alloc] init];
        centerDivider.backgroundColor = [UIColor lightGrayColor];
        
        UIButton *playButton = self.playButton = [[UIButton alloc] init];
        
        iCarousel *carousel = self.carousel = [[iCarousel alloc] init];
        carousel.dataSource = self;
        carousel.delegate = self;
        
        [self.contentView addSubview:thumbnail];
        [self.contentView addSubview:titleLabel];
        [self.contentView addSubview:descriptionLabel];
        [self.contentView addSubview:dateLabel];
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
    const float dividerX = cellWidth / 2;
    
    float x = kCellMarginLeft;
    self.thumbnail.frame = CGRectMake(x, kCellMarginTop, 50, contentHeight);
    
    x += 50 + kCellMarginLeft;
    self.titleLabel.frame = CGRectMake(x, kCellMarginTop, dividerX - x, contentHeight / 3);
    self.descriptionLabel.frame = CGRectMake(x, kCellMarginTop + contentHeight / 3, dividerX - x, contentHeight / 3);
    self.dateLabel.frame = CGRectMake(x, kCellMarginTop + contentHeight * 2 / 3, dividerX - x, contentHeight / 3);
    
    //center divider
    self.centerDivider.frame = CGRectMake(dividerX, kCellMarginTop, 1, contentHeight);
    
    self.carousel.frame = CGRectMake(dividerX + 20, kCellMarginTop, cellWidth - dividerX - 20 * 2, contentHeight);
    self.carousel.clipsToBounds = YES;
}

- (void)dealloc {
    self.thumbnail = nil;
    self.titleLabel = nil;
    self.descriptionLabel = nil;
    self.dateLabel = nil;
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
