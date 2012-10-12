//
//  HotListCell.m
//  Neonan
//
//  Created by capricorn on 12-10-12.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "HotListCell.h"

const float kCellMarginLeft = 8;
const float kCellMarginTop = 12;
const float kCellMarginBottom = 12;

@implementation HotListCell
@synthesize thumbnail = _thumbnail, titleLabel = _titleLabel,
descriptionLabel = _descriptionLabel, dateLabel = _dateLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.thumbnail = [[[UIImageView alloc] init] autorelease];
        self.titleLabel = [[[UILabel alloc] init] autorelease];
        self.descriptionLabel = [[[UILabel alloc] init] autorelease];
        self.dateLabel = [[[UILabel alloc] init] autorelease];
        
        [self.contentView addSubview:_thumbnail];
        [self.contentView addSubview:_titleLabel];
        [self.contentView addSubview:_descriptionLabel];
        [self.contentView addSubview:_dateLabel];
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
    
    float x = kCellMarginLeft;
    self.thumbnail.frame = CGRectMake(x, kCellMarginTop, 80, cellHeight - kCellMarginTop - kCellMarginBottom);
    
    x += 80 + kCellMarginLeft;
    self.titleLabel.frame = CGRectMake(x, kCellMarginTop, cellWidth - x, cellHeight / 3);
    self.descriptionLabel.frame = CGRectMake(x, kCellMarginTop + cellHeight / 3, cellWidth - x, cellHeight / 3);
    self.dateLabel.frame = CGRectMake(x, kCellMarginTop + cellHeight * 2 / 3, cellWidth - x, cellHeight / 3);
}

- (void)dealloc {
    self.thumbnail = nil;
    self.titleLabel = nil;
    self.descriptionLabel = nil;
    self.dateLabel = nil;
    [super dealloc];
}

@end
