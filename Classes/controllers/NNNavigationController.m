//
//  NNNavigationController.m
//  Neonan
//
//  Created by capricorn on 12-10-26.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "NNNavigationController.h"
#import <PrettyKit.h>

@interface NNNavigationController ()
@property (strong, nonatomic) UIButton *backButton;
@end

@implementation NNNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        PrettyNavigationBar *navigationBar = [[PrettyNavigationBar alloc] init];
        //    navigationBar.topLineColor = [UIColor blackColor];
        //    navigationBar.bottomLineColor = [UIColor blackColor];
        //    navigationBar.gradientStartColor = [UIColor blackColor];
        //    navigationBar.gradientEndColor = [UIColor blackColor];

        UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake((320 - 86) / 2, (44 - 26) / 2, 86, 26)];
        logoView.image = [UIImage imageNamed:@"img_logo.png"];
        [navigationBar addSubview:logoView];
        
        [self setValue:navigationBar forKeyPath:@"navigationBar"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.backButton = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showCustomBackButton:(UIViewController *)controller {
    if (!_backButton) {
        UIImage *image = [UIHelper imageFromFile:@"icon_left_arrow_white.png"];
        UIButton *backButton = self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, (44 - image.size.height) / 2, image.size.width, image.size.height)];
        [backButton setBackgroundImage:image forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    }
    _backButton.hidden = NO;
    controller.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_backButton];
}

#pragma mark - Private methods

- (void)back {
    [self popViewControllerAnimated:YES];
    self.backButton.hidden = YES;
}

@end
