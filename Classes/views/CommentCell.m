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

@implementation CommentCell

+ (CGFloat)getContentWidth:(CGFloat)width {
    return width - kMargin * 2;
}

+ (CGFloat)getFixedPartHeight {
    return kMargin * 2 + 15 + kGap;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.customBackgroundColor = [UIColor blackColor];
        self.customSeparatorColor = [UIColor lightGrayColor];
        
        float layoutY = kMargin;
        UILabel *userNameLabel = self.userNameLabel = [[UILabel alloc] init];
        userNameLabel.backgroundColor = [UIColor clearColor];
        userNameLabel.textColor = [UIColor whiteColor];
        
        UILabel *timeLabel = self.timeLabel = [[UILabel alloc] init];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.textColor = [UIColor whiteColor];
        timeLabel.textAlignment = NSTextAlignmentRight;
        
        UIImageView *arrowView = self.arrowView = [[UIImageView alloc] init];
        arrowView.image = [UIImage imageFromFile:@"down_arrow.png"];
        
        layoutY += kGap + 15;
        UILabel *commentLabel = self.commentLabel = [[UILabel alloc] init];
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

- (void)layoutSubviews {
    [super layoutSubviews];
    
    float layoutY = kMargin;
    self.userNameLabel.frame = CGRectMake(kMargin, layoutY, 200, 15);
    self.timeLabel.frame = CGRectMake(kMargin + 200, layoutY, 320 - kMargin - 200 - kMargin, 15);
    
    self.arrowView.frame = CGRectMake(320 - kMargin - 22, self.frame.size.height - kMargin, 15, 10);
    
    layoutY += kGap + 15;
    self.commentLabel.frame = CGRectMake(kMargin, layoutY, 320 - kMargin * 2, self.frame.size.height - [CommentCell getFixedPartHeight]);
}

@end
