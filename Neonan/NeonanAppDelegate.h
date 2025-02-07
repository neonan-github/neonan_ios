//
//  NeonanAppDelegate.h
//  Neonan
//
//  Created by bigbear on 10/11/12.
//  Copyright (c) 2012 neonan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "NNContainerViewController.h"
#import "SplashViewController.h"

@interface NeonanAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) NNContainerViewController *containerController;
@property (nonatomic, strong) SplashViewController *splashViewController;

- (ContentType)judgeContentType:(id)item;
- (void)navigationController:(UINavigationController *)navigationController pushViewControllerByType:(id)dataItem andChannel:(NSString *)channel;

@end
