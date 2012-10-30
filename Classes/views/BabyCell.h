//
//  BabyCell.h
//  Neonan
//
//  Created by capricorn on 12-10-15.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iCarousel.h>
#import <PrettyKit.h>

@interface BabyCell : PrettyTableViewCell <iCarouselDataSource, iCarouselDelegate>
@property (nonatomic, unsafe_unretained) UIImageView *thumbnail;
@property (nonatomic, unsafe_unretained) UILabel *titleLabel;
@property (nonatomic, unsafe_unretained) UILabel *scoreLabel;// 投票数
@property (nonatomic, unsafe_unretained) UIButton *voteButton;

@property (nonatomic, unsafe_unretained) UIImageView *arrowView;
@property (nonatomic, unsafe_unretained) UIButton *playButton;

@property (nonatomic, strong) NSArray *videoShots;
@end
