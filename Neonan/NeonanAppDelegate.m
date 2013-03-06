//
//  NeonanAppDelegate.m
//  Neonan
//
//  Created by bigbear on 10/11/12.
//  Copyright (c) 2012 neonan. All rights reserved.
//

#import "NeonanAppDelegate.h"
#import "MainController.h"

#import "NNURLCache.h"

#import "ArticleDetailController.h"
#import "VideoPlayController.h"
#import "GalleryDetailController.h"

#import "APService.h"
//#import "Flurry.h"
#import "MobClick.h"
#import "Harpy.h"

#import <AFNetworkActivityIndicatorManager.h>

@implementation NeonanAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    [Flurry startSession:@"VKBQM8MR7GP8V94YR43B"];
    [MobClick startWithAppkey:UMengAppKey];
    
    [application setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    [NSURLCache setSharedURLCache:[self createURLCache]];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
#ifndef DEBUG
    // JPush
    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeSound |
                                                   UIRemoteNotificationTypeAlert)];
    [APService setupWithOption:launchOptions];
#endif
    
    self.navController = [[NNNavigationController alloc] init];
    self.navController.logoHidden = NO;
    self.window.rootViewController = self.navController;
       
    UIViewController *controller = [[MainController alloc] init];
    [self.navController pushViewController:controller animated:NO];
    
//    NSDictionary *remoteNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
//    if (remoteNotif) {
//        [self enterControllerByType:[remoteNotif objectForKey:@"content_type"] andId:[remoteNotif objectForKey:@"content_id"]];
//    }
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [Harpy checkVersionDaily];
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
#ifndef DEBUG
    // JPush
    [APService registerDeviceToken:deviceToken];
#endif
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
#ifndef DEBUG
    // JPush
    [APService handleRemoteNotification:userInfo];
#endif
    
//    if (application.applicationState == UIApplicationStateActive) {
//        return;
//    }
//    
//    [self.navController popToRootViewControllerAnimated:NO];
//    [self.navController dismissModalViewControllerAnimated:NO];
//    
//    NSLog(@"userInfo:%@", userInfo);
//    [self enterControllerByType:[userInfo objectForKey:@"content_type"] andId:[userInfo objectForKey:@"content_id"]];
}

#pragma mark - Private methods

- (void)enterControllerByType:(NSString *)contentType andId:(NSString *)contentId {
    Class controllerClass;
    if ([contentType isEqualToString:@"article"]) {
        controllerClass = [ArticleDetailController class];
    } else if ([contentType isEqualToString:@"video"]) {
        controllerClass = [VideoPlayController class];
    } else {
        controllerClass = [GalleryDetailController class];
    }
    
    id controller = [[controllerClass alloc] init];
    [controller setContentId:contentId];
    if ([controller respondsToSelector:@selector(setChannel:)]) {
        [controller setChannel:@"home"];
    }
    
    if ([controller respondsToSelector:@selector(setContentType:)]) {
        [controller setContentType:contentType];
    }
    
    [self.navController pushViewController:controller animated:YES];
}

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
