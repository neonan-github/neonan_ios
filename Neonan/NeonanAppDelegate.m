//
//  NeonanAppDelegate.m
//  Neonan
//
//  Created by bigbear on 10/11/12.
//  Copyright (c) 2012 neonan. All rights reserved.
//

#import "NeonanAppDelegate.h"
#import "MainController.h"
#import "BabyDetailController.h"
#import "CommentListController.h"
#import "SignController.h"
#import "ArticleDetailController.h"
#import "NNNavigationController.h"

@implementation NeonanAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [application setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:1024 * 1024 diskCapacity:1024 * 1024 * 5 diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    self.navController = [[NNNavigationController alloc] init];
    self.window.rootViewController = self.navController;
       
    UIViewController *controller = [[MainController alloc] init];
    [self.navController pushViewController:controller animated:NO];
    self.navController.navigationItem.leftBarButtonItem = nil;
    
//    [(NeonanViewController *)controller launch];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:@"test5@neonan.com", @"email", @"4783C9E55D93F1215FAEQ1E6980EE622", @"password", nil];
    NSMutableURLRequest *request = [[NNHttpClient sharedClient] requestWithMethod:@"POST" path:@"register" parameters:parameters];
    AFHTTPRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"Response: %@\n%@", response.MIMEType, [JSON class]);
        NSDictionary *dic = JSON;
        [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSLog(@"%@ %@", key, [obj objectForKey:@"message"]);
        }];
        for (id attributes in JSON) {
            NSLog(@"attributes:%@\n", [attributes class]);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"%@", [error localizedDescription]);
    }];
    [operation start];
//    [[NNHttpClient sharedClient] postPath:@"register" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSString *text = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSLog(@"Response: %@", text);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"%@", [error localizedDescription]);
//    }];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
//    [_rootViewController enterBackground];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
//    [_rootViewController enterForeground];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
//    [_rootViewController exit];
}

@end
