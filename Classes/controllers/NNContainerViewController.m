//
//  NNContainerViewController.m
//  Neonan
//
//  Created by capricorn on 13-5-23.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "NNContainerViewController.h"

@interface NNContainerViewController ()

@end

@implementation NNContainerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setViewControllers:(NSArray *)viewControllers {
    _viewControllers = [viewControllers copy];
    self.selectedIndex = 0;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    [self.currentViewController willMoveToParentViewController:nil];
    
    UIViewController *newViewController = self.viewControllers[selectedIndex];
    [self addChildViewController:newViewController];
    [self.view addSubview:newViewController.view];
    
    [self.currentViewController willMoveToParentViewController:nil];
    [self.currentViewController.view removeFromSuperview];
    [self.currentViewController removeFromParentViewController];
    [newViewController didMoveToParentViewController:self];
    
    self.currentViewController = newViewController;
    _selectedIndex = selectedIndex;
}

- (BOOL)shouldAutorotate {
    return self.autoRotate;
}

- (NSUInteger)supportedInterfaceOrientations {
    return self.autoRotate ? UIInterfaceOrientationMaskAllButUpsideDown : UIInterfaceOrientationMaskPortrait;
}

// pre-iOS 6 support
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return self.autoRotate ? (toInterfaceOrientation != UIDeviceOrientationPortraitUpsideDown) :
    (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
