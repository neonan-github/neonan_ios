//
//  ArticleDetailController.h
//  Neonan
//
//  Created by capricorn on 12-10-23.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ActionCommon = 0,
    ActionNext,
    ActionPrevious,
} ActionType;

@interface ArticleDetailController : UIViewController

@property (assign, nonatomic) ActionType actionType;
@property (copy, nonatomic) NSString *contentId;
@property (copy, nonatomic) NSString *contentTitle;

@end
