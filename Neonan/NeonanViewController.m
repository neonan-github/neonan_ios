//
//  NeonanViewController.m
//  Neonan
//
//  Created by bigbear on 10/11/12.
//  Copyright (c) 2012 neonan. All rights reserved.
//

#import "NeonanViewController.h"
#import "RootMediator.h"

@implementation NeonanViewController

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
    [_nav release];
    [super dealloc];
}

- (void)launch
{
    NSLog(@"==> @(Just for test): 程序启动");
    _nav = [[Navigator alloc] initWithRootMediator:[[[RootMediator alloc] init] autorelease] withRootView:self.view];
}

- (void)enterBackground
{
    NSLog(@"==> @(Just for test): 程序调到后台");
}

- (void)enterForeground
{
    NSLog(@"==> @(Just for test): 程序调到前台");
}

- (void)exit
{
    NSLog(@"==> @(Just for test): 程序退出");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"==> @(Just for test): 内存警告，释放其他页面，返回首页");
    [_nav popToRootMediatorWithAnimation:None];
}

@end
