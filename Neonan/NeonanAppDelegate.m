//

//  NeonanAppDelegate.m
//  Neonan
//
//  Created by bigbear on 10/11/12.
//  Copyright (c) 2012 neonan. All rights reserved.
//

#import "NeonanAppDelegate.h"

#import "ArticleDetailViewController.h"
#import "VideoPlayViewController.h"
#import "GalleryDetailViewController.h"

#import "MottoViewController.h"
#import "TourViewController.h"
#import "LeftMenuViewController.h"
#import "RightMenuViewController.h"
#import "HomeViewController.h"

#import "ChannelListViewController.h"

#import "CommonListModel.h"

#import "NNURLCache.h"
#import "EncourageHelper.h"
#import "WeChatSharer.h"

#import "APService.h"
#import "WXApi.h"
#import "MobClick.h"
#import "Harpy.h"
#import "MKStoreManager.h"
#import "PurchaseManager.h"
#import "LockManager.h"

#import "JASidePanelController.h"

#import <AFNetworkActivityIndicatorManager.h>

static NSString *const kTouredKey = @"toured";

@interface NeonanAppDelegate ()

@property (nonatomic, strong) HomeViewController *homeViewController;

@end

@implementation NeonanAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [MobClick startWithAppkey:UMengAppKey];
    
    application.applicationIconBadgeNumber = 0;
//    [application setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    [NSURLCache setSharedURLCache:[self createURLCache]];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    // http://www.iwangke.me/2012/06/14/tips_for_mkstorekit/
#ifdef DEBUG
    [[MKStoreManager sharedManager] removeAllKeychainData];
#endif
    [MKStoreManager sharedManager];
    
    [self notifyServerOnActive];
    
    NNContainerViewController *containerController = [[NNContainerViewController alloc] init];
    self.containerController = containerController;
    
    JASidePanelController *panelController = [[JASidePanelController alloc] init];
    panelController.shouldDelegateAutorotateToVisiblePanel = YES;
    panelController.recognizesPanGesture = NO;
    panelController.leftFixedWidth = 200;
    panelController.leftPanel = [[LeftMenuViewController alloc] init];
    panelController.rightFixedWidth = 200;
    panelController.rightPanel = [[RightMenuViewController alloc] init];
    panelController.centerPanel = containerController;
    
    self.window.rootViewController = panelController;
    [self.window makeKeyAndVisible];
    
#ifndef DEBUG
    // JPush
    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeSound |
                                                   UIRemoteNotificationTypeAlert)];
    [APService setupWithOption:launchOptions];
#endif
    
    [self.homeViewController performSelector:@selector(requestData)];
    
    SplashViewController *splashViewController = self.splashViewController = [[SplashViewController alloc] init];
    splashViewController.done = ^(MottoModel *motto){
        NSDictionary *remoteNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (remoteNotif) {
            DLog(@"remote notif: %@", remoteNotif);
            [self whenNotificationArrive:remoteNotif];
        } else if (![UserDefaults boolForKey:kTouredKey]) {
            TourViewController *viewController = [[TourViewController alloc] init];
            [self.containerController presentModalViewController:viewController animated:NO];
            
            [UserDefaults setBool:YES forKey:kTouredKey];
            [UserDefaults synchronize];
        } else if (motto) {
            MottoViewController *viewController = [[MottoViewController alloc] init];
            viewController.motto = motto;
            [self.containerController presentModalViewController:viewController animated:NO];
        }
        
        containerController.viewControllers = [self createSubControllers];
        
        self.homeViewController = nil;
        self.splashViewController = nil;
    };
    [self.containerController presentModalViewController:splashViewController animated:NO];
    
    //向微信注册
    [WXApi registerApp:WeChatAppKey];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [WXApi handleOpenURL:url delegate:(WeChatSharer *)[WeChatSharer sharedSharer]];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [WXApi handleOpenURL:url delegate:(WeChatSharer *)[WeChatSharer sharedSharer]];
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [self notifyServerOnActive];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[PurchaseManager sharedManager] commitUnnotifiedInfo:nil];
    
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
    
    DLog(@"userInfo:%@", userInfo);
    
    if (application.applicationState != UIApplicationStateActive) {
        [self whenNotificationArrive:userInfo];
    }
    
    application.applicationIconBadgeNumber = 0;
}

#pragma mark - Public methods

- (ContentType)judgeContentType:(id)item {
    NSString *type = [item contentType];
    if ([type isEqualToString:@"article"]) {
        return ContentTypeArticle;
    }
    
    if ([type isEqualToString:@"video"]) {
        return ContentTypeVideo;
    }
    
    return ContentTypeSlide;
}

- (void)navigationController:(UINavigationController *)navigationController pushViewControllerByType:(id)dataItem andChannel:(NSString *)channel {
    id controller;
    
    switch ([self judgeContentType:dataItem]) {
        case ContentTypeArticle:
            controller = [[ArticleDetailViewController alloc] init];
            [controller setContentId:[dataItem contentId]];
            [controller setContentTitle:[dataItem title]];
            [controller setChannel:channel];
            break;
            
        case ContentTypeSlide:
            controller = [[GalleryDetailViewController alloc] init];
            [controller setContentType:[dataItem contentType]];
            [controller setContentId:[dataItem contentId]];
            [controller setContentTitle:[dataItem title]];
            [controller setChannel:channel];
            break;
            
        case ContentTypeVideo:
            controller = [[VideoPlayViewController alloc] init];
            [controller setContentId:[dataItem contentId]];
            [controller setVideoUrl:[dataItem videoUrl]];
            [controller setTitle:[dataItem title]];
    }
    
    [navigationController pushViewController:controller animated:YES];
}

#pragma mark - Private methods

- (HomeViewController *)homeViewController {
    if (!_homeViewController) {
        _homeViewController = [[HomeViewController alloc] init];
    }
    
    return _homeViewController;
}

- (NSArray *)createSubControllers {
    NSMutableArray *subControllers = [NSMutableArray array];
    
    HomeViewController *viewController0 = self.homeViewController;
    [subControllers addObject:[[NNNavigationController alloc] initWithRootViewController:viewController0]];
    
    NSArray *channels = [LockManager sharedManager].isContentLocked ? @[@"know", @"play", @"video"] : @[@"women", @"know", @"play", @"video"];
    NSArray *titles = [LockManager sharedManager].isContentLocked ? @[@"知道", @"爱玩", @"视频"] : @[@"女人", @"知道", @"爱玩", @"视频"];
    [channels enumerateObjectsUsingBlock:^(NSString *channel, NSUInteger idx, BOOL *stop) {
        ChannelListViewController *viewController = [[ChannelListViewController alloc] init];
        viewController.channel = channel;
        viewController.title = titles[idx];
        
        [subControllers addObject:[[NNNavigationController alloc] initWithRootViewController:viewController]];
    }];
    
    return [NSArray arrayWithArray:subControllers];
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

- (void)notifyServerOnActive {
    if ([[SessionManager sharedManager] canAutoLogin]) {
        [[SessionManager sharedManager] requsetToken:nil success:^(NSString *token) {
            [EncourageHelper doEncourage:@{@"token": token, @"type_id": @(2)} success:nil];
        }];
    }
}

- (CommonItem *)parseNotifictionInfo:(NSDictionary *)info {
    if (!info[@"content_id"]) {
        return nil;
    }
    
    CommonItem *item = [[CommonItem alloc] init];
    item.contentType = info[@"content_type"];
    item.contentId = info[@"content_id"];
    item.videoUrl = info[@"video_url"];
    item.title = info[@"title"];
    
    return item;
}

- (void)whenNotificationArrive:(NSDictionary *)info {
    CommonItem *item = [self parseNotifictionInfo:info];
    if (item) {
        [self.containerController dismissModalViewControllerAnimated:YES];
        self.containerController.sidePanelController.centerPanel = self.containerController.sidePanelController.centerPanel;
        
        NNNavigationController *topNavController = (NNNavigationController *)self.containerController.currentViewController;
        [self navigationController:topNavController pushViewControllerByType:item andChannel:nil];
    }
}

@end
