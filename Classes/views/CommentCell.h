//
//  CommentCell.h
//  Neonan
//
//  Created by capricorn on 12-10-19.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentCell : UITableViewCell
@property (nonatomic, retain) UILabel *userNameLabel;
@property (nonatomic, retain) UILabel *timeLabel;
@property (nonatomic, retain) UILabel *commentLabel;
@property (nonatomic, retain) UIImageView *arrowView;

+ (float)getCellMargin;
@end
