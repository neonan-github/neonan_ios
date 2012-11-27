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
#import <UIImageView+WebCache.h>

@protocol BabyCellDelegate;

@interface BabyCell : PrettyTableViewCell <iCarouselDataSource, iCarouselDelegate>
@property (nonatomic, unsafe_unretained) UIImageView *thumbnail;
@property (nonatomic, unsafe_unretained) UILabel *titleLabel;
@property (nonatomic, unsafe_unretained) UILabel *scoreLabel;// 投票数
@property (nonatomic, unsafe_unretained) UIButton *voteButton;

@property (nonatomic, unsafe_unretained) UIImageView *arrowView;

@property (nonatomic, strong) NSArray *videoShots;
@property (nonatomic, strong) NSArray *videoUrls;
@property (nonatomic, assign) BOOL voted;

@property (nonatomic, unsafe_unretained) id<BabyCellDelegate> delegate;

- (void)reset;
@end

@protocol BabyCellDelegate <NSObject>

- (void)playVideo:(NSString *)videoUrl;
- (void)voteBabyAtIndex:(NSInteger)index;

@end