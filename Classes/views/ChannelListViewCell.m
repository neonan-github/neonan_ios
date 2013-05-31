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

@interface ChannelListViewCell ()

@property (nonatomic, strong) CALayer *leftLineLayer;

@property (nonatomic, weak) UIImageView *contentTypeView;

@end

@implementation ChannelListViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.customBackgroundColor = DarkThemeColor;
        self.customSeparatorColor = HEXCOLOR(0x1a1a1a);
        self.selectionGradientStartColor = HEXCOLOR(0x1e1e1e);
        self.selectionGradientEndColor = HEXCOLOR(0x1e1e1e);
        
        self.thumbnail = self.imageView;
        
        UIImageView *tagImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        self.tagImageView = tagImageView;
        tagImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
        [self.thumbnail addSubview:tagImageView];
        
        TTTAttributedLabel *titleLabel = [[TTTAttributedLabel alloc] init];
        self.titleLabel = titleLabel;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.numberOfLines = 2;
        titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        titleLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
        titleLabel.font = [UIFont systemFontOfSize:13];
        
        UIImageView *contentTypeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
        self.contentTypeView = contentTypeView;
        
        TTTAttributedLabel *dateLabel = [[TTTAttributedLabel alloc] init];
        self.dateLabel = dateLabel;
        dateLabel.textAlignment = NSTextAlignmentRight;
        dateLabel.backgroundColor = [UIColor clearColor];
        dateLabel.textColor = HEXCOLOR(0x777777);
        dateLabel.font = [UIFont systemFontOfSize:9];
        dateLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentBottom;
        
        CALayer *leftLineLayer = [CALayer layer];
        self.leftLineLayer = leftLineLayer;
        leftLineLayer.frame = CGRectMake(0, 0, 1, 69);
        leftLineLayer.backgroundColor = HEXCOLOR(0x0096ff).CGColor;
        [self.layer addSublayer:leftLineLayer];
        
        [self.contentView addSubview:titleLabel];
        [self.contentView addSubview:contentTypeView];
        [self.contentView addSubview:dateLabel];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    self.leftLineLayer.opacity = self.selected || self.highlighted ? 1 : 0;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    self.leftLineLayer.opacity = self.selected || self.highlighted ? 1 : 0;
}

- (void)setViewed:(BOOL)viewed {
    _titleLabel.textColor = viewed ? HEXCOLOR(0x777777) : [UIColor whiteColor];
    _dateLabel.textColor = viewed ? HEXCOLOR(0x555555) : HEXCOLOR(0x777777);
}

- (void)setContentType:(NSString *)contentType {
    NSString *imageName;
    
    if ([contentType isEqualToString:@"video"]) {
        imageName = @"icon_content_type_video";
    } else if ([contentType isEqualToString:@"article"]) {
        imageName = @"icon_content_type_article";
    } else {
        imageName = @"icon_content_type_gallery";
    }
    
    self.contentTypeView.image = [UIImage imageNamed:imageName];
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
    self.titleLabel.frame = CGRectMake(x, kCellMarginTop, cellWidth - x - 5, contentHeight * 2 / 3);
    self.dateLabel.frame = CGRectMake(x, kCellMarginTop + contentHeight * 2 / 3 + 3, 55, contentHeight / 3);
    self.contentTypeView.frame = CGRectMake(cellWidth - 20, cellHeight - 14, 12, 12);
    
//    self.tagImageView.center = self.thumbnail.center;
}

@end
