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
@property (nonatomic, unsafe_unretained) UILabel *userNameLabel;
@property (nonatomic, unsafe_unretained) UILabel *timeLabel;
@property (nonatomic, unsafe_unretained) UILabel *commentLabel;
@property (nonatomic, unsafe_unretained) UIImageView *arrowView;
@property (nonatomic, assign) BOOL expanded;

+ (CGFloat)getContentWidth:(CGFloat)width;
+ (CGFloat)getFixedPartHeight;
+ (UIFont *)getCommentFont;
@end
