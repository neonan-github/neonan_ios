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
@property (copy, nonatomic) NSString *channel;
@property (copy, nonatomic) NSString *contentId;
@property (copy, nonatomic) NSString *contentTitle;

//@property (nonatomic, assign) NSInteger currentIndex;
//@property (nonatomic, assign) NSInteger maxIndex;

@end
