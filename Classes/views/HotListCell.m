//
//  HotListCell.m
//  Neonan
//
//  Created by capricorn on 12-10-12.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "HotListCell.h"

static const float kCellMarginLeft = 8;
static const float kCellMarginTop = 12;
static const float kCellMarginBottom = 12;

@implementation HotListCell
@synthesize thumbnail = _thumbnail, titleLabel = _titleLabel,
descriptionLabel = _descriptionLabel, dateLabel = _dateLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UIImageView *thumbnail = self.thumbnail = [[UIImageView alloc] init];
        UILabel *titleLabel = self.titleLabel = [[UILabel alloc] init];
        UILabel *descriptionLabel = self.descriptionLabel = [[UILabel alloc] init];
        UILabel *dateLabel = self.dateLabel = [[UILabel alloc] init];
        
        [self.contentView addSubview:thumbnail];
        [self.contentView addSubview:titleLabel];
        [self.contentView addSubview:descriptionLabel];
        [self.contentView addSubview:dateLabel];
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
    
    float x = kCellMarginLeft;
    self.thumbnail.frame = CGRectMake(x, kCellMarginTop, 80, contentHeight);
    
    x += 80 + kCellMarginLeft;
    self.titleLabel.frame = CGRectMake(x, kCellMarginTop, cellWidth - x, contentHeight / 3);
    self.descriptionLabel.frame = CGRectMake(x, kCellMarginTop + contentHeight / 3, cellWidth - x, contentHeight / 3);
    self.dateLabel.frame = CGRectMake(x, kCellMarginTop + contentHeight * 2 / 3, cellWidth - x, contentHeight / 3);
}

@end
