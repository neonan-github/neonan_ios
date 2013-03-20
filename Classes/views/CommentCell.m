//
//  CommentCell.m
//  Neonan
//
//  Created by capricorn on 12-10-19.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "CommentCell.h"

static const CGFloat kHorizontalMargin = 8;
static const CGFloat kTopMargin = 5;
static const CGFloat kBottomMargin = 5;
static const CGFloat kHorizontalGap = 8;
static const CGFloat kVerticalGap = 5;
static const CGFloat kAvatarSize = 32;

static UIFont *commentFont;

@interface CommentCell ()

@property (nonatomic, weak) UIButton *emblemView;

@end

@implementation CommentCell

+ (UIFont *)getCommentFont {
    if (!commentFont) {
        commentFont = [UIFont systemFontOfSize:12];
    }
    
    return commentFont;
}

+ (CGFloat)getContentWidth:(CGFloat)width {
    return width - kHorizontalMargin * 2 - kAvatarSize - kHorizontalGap;
}

+ (CGFloat)getFixedPartHeight {
    return kTopMargin + kBottomMargin  + 18 + kVerticalGap * 2;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.customBackgroundColor = DarkThemeColor;
        self.customSeparatorColor = RGB(13, 13, 13);
        
        CGFloat layoutX = kHorizontalMargin;
        CGFloat layoutY = kTopMargin;
        
        UIImageView *avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(layoutX, layoutY, kAvatarSize, kAvatarSize)];
        avatarView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
        avatarView.image = [UIImage imageNamed:@"img_default_avatar.jpg"];
        self.avatarView = avatarView;
        [self addSubview:avatarView];
        
        UIButton *emblemView = [[UIButton alloc] initWithFrame:CGRectMake(layoutX + kAvatarSize - 10, layoutY + kAvatarSize - 10, 15, 15)];
        emblemView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
        emblemView.userInteractionEnabled = NO;
        emblemView.titleLabel.font = [UIFont systemFontOfSize:7];
        self.emblemView = emblemView;
        [self addSubview:emblemView];
        
        layoutX += kAvatarSize + kHorizontalGap;
        UILabel *userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(layoutX, layoutY, 150, 10)];
        userNameLabel.font = [UIFont systemFontOfSize:10];
        userNameLabel.backgroundColor = [UIColor clearColor];
        userNameLabel.textColor = [UIColor whiteColor];
        self.userNameLabel = userNameLabel;
        [self addSubview:userNameLabel];
        
        layoutX = self.width - kHorizontalMargin - 100;
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(layoutX, layoutY, 100, 10)];
        timeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        timeLabel.font = [UIFont systemFontOfSize:10];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.textColor = [UIColor whiteColor];
        timeLabel.textAlignment = NSTextAlignmentRight;
        self.timeLabel = timeLabel;
        [self addSubview:timeLabel];
        
        layoutX = self.width - kHorizontalMargin - 12;
        UIImageView *arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(layoutX, self.height - kBottomMargin - 8, 12, 8)];
        arrowView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        arrowView.image = [UIImage imageFromFile:@"icon_down_arrow.png"];
        self.arrowView = arrowView;
        [self addSubview:arrowView];
        
        layoutX = kHorizontalMargin + kAvatarSize + kHorizontalGap;
        layoutY += kVerticalGap + 10;
        UILabel *commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(layoutX, layoutY,  [CommentCell getContentWidth:self.width], self.height - [CommentCell getFixedPartHeight])];
        commentLabel.font = [CommentCell getCommentFont];
        commentLabel.backgroundColor = [UIColor clearColor];
        commentLabel.textColor = [UIColor whiteColor];
        commentLabel.textAlignment = NSTextAlignmentLeft;
        self.commentLabel = commentLabel;
        [self addSubview:commentLabel];
        
    }
    return self;
}

- (void)setVip:(BOOL)vip andLevel:(NSInteger)level {
    [_emblemView setBackgroundImage:[UIImage imageNamed:vip ? @"icon_vip.png" : @"icon_level.png"] forState:UIControlStateNormal];
    [_emblemView setTitle:vip ? @"" : @(level).stringValue forState:UIControlStateNormal];
}

- (void)setExpanded:(BOOL)expanded {
    if (_expanded != expanded) {
        _expanded = expanded;
        
        _arrowView.transform = CGAffineTransformMakeRotation(expanded ? M_PI : 0);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = self.commentLabel.frame;
    frame.size.height = self.frame.size.height - [CommentCell getFixedPartHeight];
    self.commentLabel.frame = frame;
}

@end
