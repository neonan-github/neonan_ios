//
//  CommentCell.m
//  Neonan
//
//  Created by capricorn on 12-10-19.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "CommentCell.h"

static const CGFloat kHorizontalMargin = 10;
static const CGFloat kTopMargin = 10;
static const CGFloat kBottomMargin = 10;
static const CGFloat kHorizontalGap = 10;
static const CGFloat kVerticalGap = 5;
static const CGFloat kAvatarSize = 43;

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
    return kTopMargin + kVerticalGap + 14 + kBottomMargin;
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.customBackgroundColor = DarkThemeColor;
        self.customSeparatorColor = HEXCOLOR(0x232323);
        
        CGFloat layoutX = kHorizontalMargin;
        CGFloat layoutY = kTopMargin;
        
        UIImageView *avatarView = self.imageView;
        self.avatarView = avatarView;
        avatarView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
        avatarView.image = [UIImage imageNamed:@"img_default_avatar.jpg"];
        
        UIButton *emblemView = [[UIButton alloc] initWithFrame:CGRectMake(layoutX + kAvatarSize - 10, layoutY + kAvatarSize - 10, 16, 16)];
        emblemView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
        emblemView.userInteractionEnabled = NO;
        [emblemView setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        emblemView.titleLabel.font = [UIFont systemFontOfSize:7];
        self.emblemView = emblemView;
        [self addSubview:emblemView];
        
        layoutX += kAvatarSize + kHorizontalGap;
        UILabel *userNameLabel = self.textLabel;
        self.userNameLabel = userNameLabel;
        userNameLabel.frame = CGRectMake(layoutX, layoutY, 200, 14);
        userNameLabel.font = [UIFont boldSystemFontOfSize:14];
        userNameLabel.backgroundColor = [UIColor clearColor];
        userNameLabel.textColor = [UIColor whiteColor];
        [self addSubview:userNameLabel];
        
        layoutX = self.width - kHorizontalMargin - 100;
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(layoutX, layoutY, 100, 10)];
        self.timeLabel = timeLabel;
        timeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        timeLabel.font = [UIFont systemFontOfSize:9];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.textColor = [UIColor darkGrayColor];
        timeLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:timeLabel];
        
        layoutX = kHorizontalMargin + kAvatarSize + kHorizontalGap;
        layoutY += kVerticalGap + 14;
        UILabel *commentLabel = self.detailTextLabel;
        self.commentLabel = commentLabel;
        commentLabel.frame = CGRectMake(layoutX, layoutY, [CommentCell getContentWidth:self.width], 0);
        commentLabel.numberOfLines = 0;
        commentLabel.font = [CommentCell getCommentFont];
        commentLabel.backgroundColor = [UIColor clearColor];
        commentLabel.textColor = [UIColor lightTextColor];
        commentLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    return self;
}

- (void)setVip:(BOOL)vip andLevel:(NSInteger)level {
    [_emblemView setBackgroundImage:[UIImage imageNamed:vip ? @"icon_vip.png" : @"icon_level.png"] forState:UIControlStateNormal];
    [_emblemView setTitle:vip ? @"" : @(level).stringValue forState:UIControlStateNormal];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat layoutX = kHorizontalMargin;
    CGFloat layoutY = kTopMargin;
    
    self.avatarView.frame = CGRectMake(layoutX, layoutY, kAvatarSize, kAvatarSize);
    
    layoutX += kAvatarSize + kHorizontalGap;
    self.userNameLabel.frame = CGRectMake(layoutX, layoutY, 200, 14);
    
    layoutX = kHorizontalMargin + kAvatarSize + kHorizontalGap;
    layoutY += kVerticalGap + 14;
    
    UIFont *commentFont = [CommentCell getCommentFont];
    
    NSUInteger lines = [UIHelper computeContentLines:self.commentLabel.text
                                           withWidth:[CommentCell getContentWidth:CompatibleScreenWidth]
                                             andFont:commentFont];
    
    self.commentLabel.frame = CGRectMake(layoutX, layoutY, [CommentCell getContentWidth:self.width],
                                         commentFont.lineHeight * lines);
}

@end
