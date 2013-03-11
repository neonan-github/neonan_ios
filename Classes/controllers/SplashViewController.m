//
//  SplashViewController.m
//  Neonan
//
//  Created by capricorn on 13-3-11.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "SplashViewController.h"

#import "PurchaseManager.h"

@interface SplashViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end

@implementation SplashViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSString *imageName = IS_IPHONE_5 ? @"Default-568h@2x.png" : (IS_RETINA ? @"Default@2x.png" : @"Default.png");
    _imageView.image = [UIImage imageFromFile:imageName];
    
    [_activityIndicatorView startAnimating];
}

- (void)cleanUp {
    self.imageView = nil;
    self.activityIndicatorView = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[PurchaseManager sharedManager] commitUnnotifiedInfo:^{
        [self dismissModalViewControllerAnimated:NO];
    }];
}

@end
