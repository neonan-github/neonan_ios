//
//  HomeGridViewCell.h
//  Neonan
//
//  Created by capricorn on 13-5-23.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import <KKGridViewCell.h>
#import <TTTAttributedLabel.h>

@interface HomeGridViewCell : KKGridViewCell

@property (nonatomic, weak) TTTAttributedLabel *titleLabel;
@property (nonatomic, weak) UIImageView *tagImageView;

- (void)setViewed:(BOOL)viewed;

@end
