//
//  BabyDetailController.h
//  Neonan
//
//  Created by capricorn on 12-10-22.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideShowView.h"
#import "FoldableTextBox.h"

@interface BabyDetailController : UIViewController

@property (assign, nonatomic) SortType sortType;
@property (assign, nonatomic) NSUInteger offset;
@property (copy, nonatomic) NSString *channel;
@property (copy, nonatomic) NSString *contentType;
@property (copy, nonatomic) NSString *contentId;
@property (copy, nonatomic) NSString *contentTitle;
@property (assign, nonatomic) BOOL voted;

@end
