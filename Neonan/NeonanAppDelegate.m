//
//  NeonanAppDelegate.m
//  Neonan
//
//  Created by bigbear on 10/11/12.
//  Copyright (c) 2012 neonan. All rights reserved.
//

#import "NeonanAppDelegate.h"
#import "MainController.h"

#import <AFNetworkActivityIndicatorManager.h>
#import "NNURLCache.h"
#import "APService.h"

@implementation NeonanAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [application setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    
    [NSURLCache setSharedURLCache:[self createURLCache]];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    self.navController = [[NNNavigationController alloc] init];
    self.navController.logoHidden = NO;
    self.window.rootViewController = self.navController;
       
    UIViewController *controller = [[MainController alloc] init];
    [self.navController pushViewController:controller animated:NO];
    self.navController.navigationItem.leftBarButtonItem = nil;
    
    [self.window makeKeyAndVisible];
    
    // JPush Required
    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                   UIRemoteNotificationTypeSound |
                                                   UIRemoteNotificationTypeAlert)];
    [APService setupWithOption:launchOptions];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    // JPush Required
    [APService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // JPush Required
    [APService handleRemoteNotification:userInfo];
}

#pragma mark - Private methods

- (NSURLCache *)createURLCache {
//    if (SYSTEM_VERSION_LESS_THAN(@"5.0")) {
//        SDURLCache *URLCache = [[SDURLCache alloc] initWithMemoryCapacity:1024 * 1024   // 1MB mem cache
//                                                             diskCapacity:1024 * 1024 * 5 // 5MB disk cache
//                                                                 diskPath:[SDURLCache defaultCachePath]];
//        return URLCache;
//    }
    
    NSURLCache *URLCache = [[NNURLCache alloc] initWithMemoryCapacity:1024 * 1024
                                                         diskCapacity:1024 * 1024 * 5
                                                             diskPath:nil];
    return URLCache;
}

@end
