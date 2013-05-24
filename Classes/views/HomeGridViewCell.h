//
//  HomeGridViewCell.h
//  Neonan
//
//  Created by capricorn on 13-5-23.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "AQGridViewCell.h"

#import <TTTAttributedLabel.h>

@interface HomeGridViewCell : AQGridViewCell

@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) TTTAttributedLabel *titleLabel;

@end
