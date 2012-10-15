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
@property (nonatomic, retain) UIView *centerDivider;
@end

@implementation BabyCell
@synthesize thumbnail = _thumbnail, titleLabel = _titleLabel,
descriptionLabel = _descriptionLabel, dateLabel = _dateLabel;
@synthesize centerDivider = _centerDivider;
@synthesize playButton = _playButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.thumbnail = [[[UIImageView alloc] init] autorelease];
        self.titleLabel = [[[UILabel alloc] init] autorelease];
        self.descriptionLabel = [[[UILabel alloc] init] autorelease];
        self.dateLabel = [[[UILabel alloc] init] autorelease];
        
        self.centerDivider = [[[UIView alloc] init] autorelease];
        self.centerDivider.backgroundColor = [UIColor lightGrayColor];
        
        self.playButton = [[[UIButton alloc] init] autorelease];
        
        [self.contentView addSubview:self.thumbnail];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.descriptionLabel];
        [self.contentView addSubview:self.dateLabel];
        [self.contentView addSubview:self.centerDivider];
        [self.contentView addSubview:self.playButton];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
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
    
    self.playButton.frame = CGRectMake(dividerX + 20, kCellMarginTop, cellWidth - dividerX - 20 * 2, contentHeight);
}

- (void)dealloc {
    self.thumbnail = nil;
    self.titleLabel = nil;
    self.descriptionLabel = nil;
    self.dateLabel = nil;
    self.centerDivider = nil;
    self.playButton = nil;
    [super dealloc];
}

@end
