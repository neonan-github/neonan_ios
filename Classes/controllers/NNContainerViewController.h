//
//  NNContainerViewController.h
//  Neonan
//
//  Created by capricorn on 13-5-23.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NNContainerViewController : UIViewController

@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic,copy) NSArray *viewControllers;
@property (nonatomic, assign) NSInteger selectedIndex;

@end
