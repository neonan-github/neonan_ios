//
//  TopicCell.h
//  Neonan
//
//  Created by capricorn on 13-1-29.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import <PrettyKit.h>

@interface TopicCell : PrettyTableViewCell

@property (nonatomic, unsafe_unretained) UIImageView *displayView;
@property (nonatomic, unsafe_unretained) UILabel *topicLabel;

+ (CGFloat)getContentHeight:(NSString *)topic width:(CGFloat)width;

@end
