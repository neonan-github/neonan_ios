//
//  HotListCell.m
//  Neonan
//
//  Created by capricorn on 12-10-12.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "HotListCell.h"

static const float kCellMarginLeft = 10;
static const float kCellMarginTop = 5;
static const float kCellMarginBottom = 5;

@implementation HotListCell
@synthesize thumbnail = _thumbnail, titleLabel = _titleLabel,
descriptionLabel = _descriptionLabel, dateLabel = _dateLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.customBackgroundColor = RGB(26, 26, 26);
        self.customSeparatorColor = RGB(13, 13, 13);
        
        UIImageView *accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_disclosure_normal.png"] highlightedImage:[UIImage imageNamed:@"icon_disclosure_highlighted.png"]];
        self.accessoryView = accessoryView;
        
        UIImageView *thumbnail = self.thumbnail = [[UIImageView alloc] init];
        
        MSLabel *titleLabel = self.titleLabel = [[MSLabel alloc] init];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.numberOfLines = 2;
        titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        titleLabel.verticalAlignment = MSLabelVerticalAlignmentTop;
        titleLabel.font = [UIFont systemFontOfSize:9];
        
        MSLabel *descriptionLabel = self.descriptionLabel = [[MSLabel alloc] init];
        descriptionLabel.backgroundColor = [UIColor clearColor];
        descriptionLabel.textColor = [UIColor whiteColor];
        descriptionLabel.font = [UIFont systemFontOfSize:7];
        
        MSLabel *dateLabel = self.dateLabel = [[MSLabel alloc] init];
        dateLabel.backgroundColor = [UIColor clearColor];
        dateLabel.textColor = [UIColor whiteColor];
        dateLabel.font = [UIFont systemFontOfSize:6];
        dateLabel.textAlignment = NSTextAlignmentRight;
        
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
    
    const float cellHeight = self.contentView.frame.size.height;
    const float cellWidth = self.contentView.frame.size.width;
    const float contentHeight = cellHeight - kCellMarginTop - kCellMarginBottom;
    
    float x = kCellMarginLeft;
    self.thumbnail.frame = CGRectMake(x, kCellMarginTop, 75, contentHeight);
    
    x += 75 + kCellMarginLeft;
    self.titleLabel.frame = CGRectMake(x, kCellMarginTop, cellWidth - x, contentHeight * 2 / 3);
    self.descriptionLabel.frame = CGRectMake(x, kCellMarginTop + contentHeight * 2 / 3, cellWidth - x, contentHeight / 3);
    self.dateLabel.frame = CGRectMake(cellWidth - 75, kCellMarginTop + contentHeight * 2 / 3, 55, contentHeight / 3);
}

@end
