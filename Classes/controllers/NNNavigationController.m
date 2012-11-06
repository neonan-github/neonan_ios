//
//  NNNavigationController.m
//  Neonan
//
//  Created by capricorn on 12-10-26.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "NNNavigationController.h"
#import "CustomNavigationBar.h"

@interface NNNavigationController ()
@end

@implementation NNNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        CustomNavigationBar *navigationBar = [[CustomNavigationBar alloc] init];
        navigationBar.topLineColor = RGB(32, 32, 32);
        navigationBar.bottomLineColor = RGB(32, 32, 32);
        navigationBar.gradientStartColor = RGB(32, 32, 32);
        navigationBar.gradientEndColor = RGB(32, 32, 32);
//        navigationBar.tintColor = [UIColor blackColor];
        navigationBar.navigationController = self;

        UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake((CompatibleScreenWidth - 85) / 2, (NavBarHeight - 19) / 2, 85, 19)];
        logoView.image = [UIImage imageFromFile:@"img_logo.png"];
        [navigationBar addSubview:logoView];
        
        [self setValue:navigationBar forKeyPath:@"navigationBar"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
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
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
