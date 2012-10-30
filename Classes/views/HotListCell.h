//
//  HotListCell.h
//  Neonan
//
//  Created by capricorn on 12-10-12.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PrettyKit.h>
#import <MSLabel.h>

@interface HotListCell : PrettyTableViewCell
@property (nonatomic, unsafe_unretained) UIImageView *thumbnail;
@property (nonatomic, unsafe_unretained) MSLabel *titleLabel;
@property (nonatomic, unsafe_unretained) MSLabel *descriptionLabel;
@property (nonatomic, unsafe_unretained) MSLabel *dateLabel;
@end
