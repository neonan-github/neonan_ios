//
//  CommentCell.h
//  Neonan
//
//  Created by capricorn on 12-10-19.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PrettyKit.h>

@interface CommentCell : PrettyTableViewCell

@property (nonatomic, weak) UIImageView *avatarView;
@property (nonatomic, weak) UILabel *userNameLabel;
@property (nonatomic, weak) UILabel *timeLabel;
@property (nonatomic, weak) UILabel *commentLabel;

+ (CGFloat)getContentWidth:(CGFloat)width;
+ (CGFloat)getFixedPartHeight;
+ (UIFont *)getCommentFont;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

- (void)setVip:(BOOL)vip andLevel:(NSInteger)level;

@end
