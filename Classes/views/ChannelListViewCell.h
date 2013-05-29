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

@property (nonatomic, unsafe_unretained) UIImageView *thumbnail;
@property (nonatomic, unsafe_unretained) TTTAttributedLabel *titleLabel;
@property (nonatomic, unsafe_unretained) TTTAttributedLabel *descriptionLabel;
@property (nonatomic, unsafe_unretained) TTTAttributedLabel *dateLabel;

- (void)setViewed:(BOOL)viewed;

@end
