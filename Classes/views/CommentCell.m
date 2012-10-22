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
@synthesize userNameLabel, timeLabel, commentLabel, arrowView;

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
        float layoutY = kMargin;
        self.userNameLabel = [[[UILabel alloc] init] autorelease];
        
        self.timeLabel = [[[UILabel alloc] init] autorelease];
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        
        self.arrowView = [[[UIImageView alloc] init] autorelease];
        self.arrowView.image = [UIImage imageNamed:@"down_arrow.png"];
        
        layoutY += kGap + 15;
        self.commentLabel = [[[UILabel alloc] init] autorelease];
        self.commentLabel.textAlignment = NSTextAlignmentLeft;
        
        [self addSubview:self.userNameLabel];
        [self addSubview:self.timeLabel];
        [self addSubview:self.commentLabel];
        [self addSubview:self.arrowView];
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

- (void)dealloc {
    self.userNameLabel = nil;
    self.timeLabel = nil;
    self.commentLabel = nil;
    self.arrowView = nil;
    
    [super dealloc];
}

@end
