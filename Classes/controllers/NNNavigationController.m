//
//  NNNavigationController.m
//  Neonan
//
//  Created by capricorn on 12-10-26.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "NNNavigationController.h"
#import "NNNavigationBar.h"

@interface NNNavigationController ()
//@property (unsafe_unretained, nonatomic) UIImageView *logoView;
@end

@implementation NNNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NNNavigationBar *navigationBar = [[NNNavigationBar alloc] init];
        navigationBar.topLineColor = RGB(0, 0, 0);
        navigationBar.bottomLineColor = RGB(0, 0, 0);
        navigationBar.gradientStartColor = RGB(0, 0, 0);
        navigationBar.gradientEndColor = RGB(0, 0, 0);
        navigationBar.tintColor = RGB(0, 0, 0);
        navigationBar.navigationController = self;

//        UIImageView *logoView = self.logoView = [[UIImageView alloc] initWithFrame:CGRectMake((CompatibleScreenWidth - 107) / 2, (NavBarHeight - 25) / 2,
//                                                                                              107, 25)];
//        logoView.image = [UIImage imageFromFile:@"img_logo.png"];
//        [navigationBar addSubview:logoView];
        
//        self.logoHidden = YES;
        
        [self setValue:navigationBar forKeyPath:@"navigationBar"];
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
}

- (void)viewDidUnload {
//    self.logoView = nil;
    
    [super viewDidUnload];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [super pushViewController:viewController animated:animated];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

// pre-iOS 6 support
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return _autoRotate ? (toInterfaceOrientation != UIDeviceOrientationPortraitUpsideDown) : (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

//- (void)setLogoHidden:(BOOL)hidden {
//    if (_logoHidden != hidden) {
//        _logoHidden = hidden;
//        
//        _logoView.hidden = hidden;
//    }
//}

@end
