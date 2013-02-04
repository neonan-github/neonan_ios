//
//  NNViewController.m
//  Bang
//
//  Created by capricorn on 12-12-21.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "NNViewController.h"
#import "NNNavigationController.h"

@interface NNViewController ()

@end

@implementation NNViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    // In iOS 6 viewWillUnload and viewDidUnload Are Deprecated
    if([self isViewLoaded] && self.view.window == nil) {
        self.view = nil;
        [self cleanUp];
    }
}

- (void)viewDidUnload {
    [self cleanUp];
    
    [self viewDidUnload];
}

- (void)dealloc {
    [self cleanUp];
}

- (void)cleanUp {
    
}

#pragma mark - UIViewController life cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.visible = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.visible = NO;
}

@end
