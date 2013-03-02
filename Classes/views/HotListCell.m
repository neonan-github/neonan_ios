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

// 图片长宽比
static const CGFloat kThumbNailRatio = 320.f / 185.f;

@implementation HotListCell
@synthesize thumbnail = _thumbnail, titleLabel = _titleLabel,
descriptionLabel = _descriptionLabel, dateLabel = _dateLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.customBackgroundColor = DarkThemeColor;
        self.customSeparatorColor = RGB(13, 13, 13);
        self.selectionGradientStartColor = DarkThemeColor;
        self.selectionGradientEndColor = DarkThemeColor;
        
        UIImageView *accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_disclosure_normal.png"] highlightedImage:[UIImage imageNamed:@"icon_disclosure_highlighted.png"]];
        self.accessoryView = accessoryView;
        
        UIImageView *thumbnail = self.thumbnail = [[UIImageView alloc] init];
        
        TTTAttributedLabel *titleLabel = self.titleLabel = [[TTTAttributedLabel alloc] init];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.numberOfLines = 2;
        titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        titleLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
        titleLabel.font = [UIFont systemFontOfSize:12];
        
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
