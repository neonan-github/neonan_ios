//
//  NeonanAppDelegate.h
//  Neonan
//
//  Created by bigbear on 10/11/12.
//  Copyright (c) 2012 neonan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NeonanViewController.h"

@interface NeonanAppDelegate : UIResponder <UIApplicationDelegate> {
    NeonanViewController *_rootViewController;
}

@property (strong, nonatomic) UIWindow *window;

@end
