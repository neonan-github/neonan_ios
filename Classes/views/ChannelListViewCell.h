//
//  ChannelListViewCell.h
//  Neonan
//
//  Created by capricorn on 13-5-29.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "PrettyTableViewCell.h"

#import <TTTAttributedLabel.h>

@interface ChannelListViewCell : PrettyTableViewCell

@property (nonatomic, weak) UIImageView *thumbnail;
@property (nonatomic, weak) UIImageView *tagImageView;
@property (nonatomic, weak) TTTAttributedLabel *titleLabel;
@property (nonatomic, weak) TTTAttributedLabel *dateLabel;

- (void)setViewed:(BOOL)viewed;
- (void)setContentType:(NSString *)contentType;

@end
