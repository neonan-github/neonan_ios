//
//  RootMediator.m
//  Neonan
//
//  Created by bigbear on 10/11/12.
//  Copyright (c) 2012 neonan. All rights reserved.
//

#import "RootMediator.h"
#import "TestMediator.h"
#import "GalleryContainerMediator.h"
#import "VideoMediator.h"

@implementation RootMediator

- (void)viewDidLoad
{
    UIButton *test = [[[UIButton alloc] initWithFrame:CGRectMake(60, 100, 200, 100)] autorelease];
    [test setBackgroundColor:[UIColor grayColor]];
    [test setTitle:@"进入测试页面" forState:UIControlStateNormal];
    [test setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [test setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [test addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:test];
}

- (void)test
{
    Mediator *test = [[[VideoMediator alloc] init] autorelease];
    [self pushMediator:test withAnimation:From_Right];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"==> @(Just for test): RootMediator Appear!!");
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"==> @(Just for test): RootMediator Disappear!!");
}

@end
