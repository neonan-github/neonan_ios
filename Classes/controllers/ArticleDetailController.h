//
//  ArticleDetailController.h
//  Neonan
//
//  Created by capricorn on 12-10-23.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArticleDetailController : NNViewController

@property (assign, nonatomic) SortType sortType;
@property (assign, nonatomic) NSUInteger offset;
@property (copy, nonatomic) NSString *channel;
@property (copy, nonatomic) NSString *contentId;
@property (copy, nonatomic) NSString *contentTitle;

@end
