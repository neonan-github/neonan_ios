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
@property (nonatomic, unsafe_unretained) UIImageView *thumbnail;
@property (nonatomic, unsafe_unretained) UILabel *titleLabel;
@property (nonatomic, unsafe_unretained) UILabel *descriptionLabel;
@property (nonatomic, unsafe_unretained) UILabel *dateLabel;
@property (nonatomic, unsafe_unretained) UIButton *playButton;

@property (nonatomic, strong) NSArray *videoShots;
@end
