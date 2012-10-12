//
//  HotListCell.h
//  Neonan
//
//  Created by capricorn on 12-10-12.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HotListCell : UITableViewCell
@property (nonatomic, retain) UIImageView *thumbnail;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *descriptionLabel;
@property (nonatomic, retain) UILabel *dateLabel;
@end
