//
//  TopicCell.m
//  Neonan
//
//  Created by capricorn on 13-1-29.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "TopicCell.h"

static const CGFloat kBorderMargin = 10;
static const CGFloat kLabelPadding = 7;
static const CGFloat kImageRatio = 9 / 16.0; // height : width

@implementation TopicCell

+ (UIFont *)getCommentFont {
    static UIFont *font;
    if (!font) {
        font = [UIFont systemFontOfSize:14];
    }
    
    return font;
}

+ (CGFloat)getContentWidth:(CGFloat)width {
    return width - kBorderMargin * 2;
}

+ (CGFloat)getContentHeight:(NSString *)topic width:(CGFloat)width {
    CGFloat contentWidth = [TopicCell getContentWidth:width];
    CGSize constraint = CGSizeMake(contentWidth, 20000.0f);
    CGSize size = [topic sizeWithFont:[TopicCell getCommentFont] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    
    return kBorderMargin + contentWidth * kImageRatio + kLabelPadding * 2 + size.height;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.customBackgroundColor = DarkThemeColor;
        self.customSeparatorColor = RGB(13, 13, 13);
        self.selectionGradientStartColor = DarkThemeColor;
        self.selectionGradientEndColor = DarkThemeColor;
        
        CGFloat contentWidth = self.width - 2 * kBorderMargin;
        UIImageView *displayView = self.displayView = [[UIImageView alloc] initWithFrame:CGRectMake(kBorderMargin, kBorderMargin,
                                                                                                contentWidth, contentWidth * kImageRatio)];
        displayView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        displayView.layer.borderWidth = 5;
        displayView.layer.borderColor = RGBA(255, 255, 255, 0.3).CGColor;
        [self addSubview:displayView];
        
        CGFloat layoutY = kBorderMargin + contentWidth * kImageRatio + kLabelPadding;
        UILabel *topicLabel = self.topicLabel = [[UILabel alloc] initWithFrame:CGRectMake(kBorderMargin, layoutY, contentWidth, 0)];
        topicLabel.backgroundColor = [UIColor clearColor];
        topicLabel.textColor = [UIColor whiteColor];
        topicLabel.numberOfLines = 0;
        topicLabel.font = [TopicCell getCommentFont];
        topicLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:topicLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat contentWidth = self.frame.size.width - 2 * kBorderMargin;
    CGFloat imgHeight = contentWidth * kImageRatio;
    _displayView.height = imgHeight;
    
    CGFloat layoutY = kBorderMargin + imgHeight + kLabelPadding;
    _topicLabel.y = layoutY;
    _topicLabel.height = self.height - layoutY - kLabelPadding;
}

@end
