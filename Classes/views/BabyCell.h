//
//  BabyCell.h
//  Neonan
//
//  Created by capricorn on 12-10-15.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iCarousel.h>

@interface BabyCell : UITableViewCell <iCarouselDataSource, iCarouselDelegate>
@property (nonatomic, retain) UIImageView *thumbnail;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *descriptionLabel;
@property (nonatomic, retain) UILabel *dateLabel;
@property (nonatomic, retain) UIButton *playButton;
@property (nonatomic, retain) NSArray *videoShots;
@end
