//
//  CommentCell.m
//  Neonan
//
//  Created by capricorn on 12-10-19.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "CommentCell.h"

static const float kMargin = 15;
static const float kGap = 8;

static UIFont *commentFont;

static UIImage *downArrowImg, *upArrowImg;

@interface CommentCell ()

+ (UIImage *)getDownArrowImg;
+ (UIImage *)getUpArrowImg;

@end

@implementation CommentCell

+ (UIFont *)getCommentFont {
    if (!commentFont) {
        commentFont = [UIFont systemFontOfSize:12];
    }
    
    return commentFont;
}

+ (CGFloat)getContentWidth:(CGFloat)width {
    return width - kMargin * 2;
}

+ (CGFloat)getFixedPartHeight {
    return kMargin * 2 + 15 + kGap;
}

+ (UIImage *)getDownArrowImg {
    if (!downArrowImg) {
        downArrowImg = [UIImage imageFromFile:@"icon_down_arrow.png"];
    }

    return downArrowImg;
}

+ (UIImage *)getUpArrowImg {
    if (!upArrowImg) {
        upArrowImg = [UIImage imageFromFile:@"icon_up_arrow.png"];
    }
    
    return upArrowImg;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.customBackgroundColor = DarkThemeColor;
        self.customSeparatorColor = RGB(13, 13, 13);
        
        float layoutY = kMargin;
        UILabel *userNameLabel = self.userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kMargin, layoutY, 200, 10)];
        userNameLabel.font = [UIFont systemFontOfSize:10];
        userNameLabel.backgroundColor = [UIColor clearColor];
        userNameLabel.textColor = [UIColor whiteColor];
        
        UILabel *timeLabel = self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kMargin + 200, layoutY, self.frame.size.width - kMargin - 200 - kMargin, 10)];
        timeLabel.font = [UIFont systemFontOfSize:10];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.textColor = [UIColor whiteColor];
        timeLabel.textAlignment = NSTextAlignmentRight;
        
        UIImageView *arrowView = self.arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - kMargin - 12, self.frame.size.height - kMargin, 12, 8)];
        arrowView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        arrowView.image = [UIImage imageFromFile:@"icon_down_arrow.png"];
        
        layoutY += kGap + 15;
        UILabel *commentLabel = self.commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(kMargin, layoutY,  [CommentCell getContentWidth:self.frame.size.width], self.frame.size.height - [CommentCell getFixedPartHeight])];
        commentLabel.font = [CommentCell getCommentFont];
        commentLabel.backgroundColor = [UIColor clearColor];
        commentLabel.textColor = [UIColor whiteColor];
        commentLabel.textAlignment = NSTextAlignmentLeft;
        
        [self addSubview:userNameLabel];
        [self addSubview:timeLabel];
        [self addSubview:commentLabel];
        [self addSubview:arrowView];
    }
    return self;
}

- (void)setExpanded:(BOOL)expanded {
    if (_expanded != expanded) {
        _expanded = expanded;
        
        _arrowView.image = expanded ? [CommentCell getUpArrowImg] : [CommentCell getDownArrowImg];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = self.commentLabel.frame;
    frame.size.height = self.frame.size.height - [CommentCell getFixedPartHeight];
    self.commentLabel.frame = frame;
}

@end
