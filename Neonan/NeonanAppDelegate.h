//
//  NeonanAppDelegate.h
//  Neonan
//
//  Created by bigbear on 10/11/12.
//  Copyright (c) 2012 neonan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainController.h"
#import "Constants.h"
#import "NNNavigationController.h"
#import "NNContainerViewController.h"

@interface NeonanAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) NNNavigationController *navController;
@property (nonatomic, strong) NNContainerViewController *containerController;

@end
