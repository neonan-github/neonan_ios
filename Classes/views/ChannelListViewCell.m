//
//  ChannelListViewCell.m
//  Neonan
//
//  Created by capricorn on 13-5-29.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "ChannelListViewCell.h"

static const float kCellMarginLeft = 10;
static const float kCellMarginTop = 5;
static const float kCellMarginBottom = 5;

// 图片长宽比
static const CGFloat kThumbNailRatio = 320.f / 185.f;

@implementation ChannelListViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.customBackgroundColor = DarkThemeColor;
        self.customSeparatorColor = HEXCOLOR(0x1a1a1a);
        self.selectionGradientStartColor = HEXCOLOR(0x1e1e1e);
        self.selectionGradientEndColor = HEXCOLOR(0x1e1e1e);
        
        UIImageView *thumbnail = self.thumbnail = [[UIImageView alloc] init];
        
        TTTAttributedLabel *titleLabel = self.titleLabel = [[TTTAttributedLabel alloc] init];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.numberOfLines = 2;
        titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        titleLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
        titleLabel.font = [UIFont systemFontOfSize:13];
        
        TTTAttributedLabel *descriptionLabel = self.descriptionLabel = [[TTTAttributedLabel alloc] init];
        descriptionLabel.textAlignment = NSTextAlignmentLeft;
        descriptionLabel.backgroundColor = [UIColor clearColor];
        descriptionLabel.textColor = HEXCOLOR(0x777777);
        descriptionLabel.font = [UIFont systemFontOfSize:9];
        descriptionLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentBottom;
        
        TTTAttributedLabel *dateLabel = self.dateLabel = [[TTTAttributedLabel alloc] init];
        dateLabel.textAlignment = NSTextAlignmentRight;
        dateLabel.backgroundColor = [UIColor clearColor];
        dateLabel.textColor = HEXCOLOR(0x777777);
        dateLabel.font = [UIFont systemFontOfSize:9];
        dateLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentBottom;
        
        [self.contentView addSubview:thumbnail];
        [self.contentView addSubview:titleLabel];
        [self.contentView addSubview:descriptionLabel];
        [self.contentView addSubview:dateLabel];
    }
    return self;
}

- (void)setViewed:(BOOL)viewed {
    _titleLabel.textColor = viewed ? HEXCOLOR(0x777777) : [UIColor whiteColor];
    _descriptionLabel.textColor = _dateLabel.textColor = viewed ? HEXCOLOR(0x555555) : HEXCOLOR(0x777777);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    const float cellHeight = self.contentView.frame.size.height;
    const float cellWidth = self.contentView.frame.size.width;
    const float contentHeight = cellHeight - kCellMarginTop - kCellMarginBottom;
    
    float x = kCellMarginLeft;
    CGFloat thumbnailWidth = contentHeight * kThumbNailRatio;
    self.thumbnail.frame = CGRectMake(x, kCellMarginTop, thumbnailWidth, contentHeight);
    
    x += thumbnailWidth + kCellMarginLeft;
    self.titleLabel.frame = CGRectMake(x, kCellMarginTop, cellWidth - x, contentHeight * 2 / 3);
    self.descriptionLabel.frame = CGRectMake(x, kCellMarginTop + contentHeight * 2 / 3, cellWidth - x, contentHeight / 3);
    self.dateLabel.frame = CGRectMake(cellWidth - 65, kCellMarginTop + contentHeight * 2 / 3 + 3, 55, contentHeight / 3);
}

@end
