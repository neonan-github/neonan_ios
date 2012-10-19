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

+ (float)getCellMargin {
    return kMargin;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        float layoutY = kMargin;
        self.userNameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(kMargin, layoutY, 200, 15)] autorelease];
        self.timeLabel = [[[UILabel alloc] initWithFrame:CGRectMake(kMargin + 200, layoutY, 320 - kMargin - 200, 15)] autorelease];
        
        self.arrowView = [[[UIImageView alloc] initWithFrame:CGRectMake(265, self.frame.size.height - kMargin, 15, 10)] autorelease];
        
        layoutY += kGap;
        self.commentLabel = [[[UILabel alloc] initWithFrame:CGRectMake(kMargin, layoutY, 320 - kMargin * 2, self.frame.size.height - (kMargin + kGap) * 2)] autorelease];
        
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
    self.timeLabel.frame = CGRectMake(kMargin + 200, layoutY, 320 - kMargin - 200, 15);
    
    self.arrowView.frame = CGRectMake(265, self.frame.size.height - kMargin, 15, 10);
    
    layoutY += kGap;
    self.commentLabel.frame = CGRectMake(kMargin, layoutY, 320 - kMargin * 2, self.frame.size.height - (kMargin + kGap) * 2);
}

- (void)dealloc {
    self.userNameLabel = nil;
    self.timeLabel = nil;
    self.commentLabel = nil;
    self.arrowView = nil;
    
    [super dealloc];
}

@end
