//
//  HotListCell.h
//  Neonan
//
//  Created by capricorn on 12-10-12.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PrettyKit.h>
#import <TTTAttributedLabel.h>
#import <UIImageView+WebCache.h>

@interface HotListCell : PrettyTableViewCell

@property (nonatomic, unsafe_unretained) UIImageView *thumbnail;
@property (nonatomic, unsafe_unretained) TTTAttributedLabel *titleLabel;
@property (nonatomic, unsafe_unretained) TTTAttributedLabel *descriptionLabel;
@property (nonatomic, unsafe_unretained) TTTAttributedLabel *dateLabel;

- (void)setViewed:(BOOL)viewed;

@end
