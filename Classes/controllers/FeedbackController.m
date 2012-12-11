//
//  FeedbackController.m
//  Neonan
//
//  Created by capricorn on 12-12-11.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "FeedbackController.h"

@interface FeedbackController ()

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *deviceInfoLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *editBackgroundView;
@property (unsafe_unretained, nonatomic) IBOutlet UITextView *editView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *ageInfoLabel;

@end

@implementation FeedbackController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIButton *navLeftButton = [UIHelper createBarButton:5];
    [navLeftButton setTitle:@"关闭" forState:UIControlStateNormal];
    [navLeftButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navLeftButton];
    
    UIButton *navRightButton = [UIHelper createBarButton:5];
    [navRightButton setTitle:@"提交" forState:UIControlStateNormal];
    [navRightButton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navRightButton];
    
    UIImage *editBgImage = [[UIImage imageFromFile:@"bg_feedback_edit.png"] stretchableImageWithLeftCapWidth:27 topCapHeight:15];
    [_editBackgroundView setImage:editBgImage];
    
    UIImageView *downArrowView = [[UIImageView alloc] initWithImage:[UIImage imageFromFile:@"icon_down_select.png"]];
    downArrowView.frame = CGRectMake(_ageInfoLabel.bounds.size.width - 20, 0, 20, 20);
    CGPoint center = downArrowView.center;
    center.y = _ageInfoLabel.bounds.size.height / 2;
    downArrowView.center = center;
    downArrowView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [_ageInfoLabel addSubview:downArrowView];
    
    UIGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ageRangeSelect)];
    [_ageInfoLabel addGestureRecognizer:tapRecognizer];
    _ageInfoLabel.userInteractionEnabled = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    self.deviceInfoLabel = nil;
    self.editBackgroundView = nil;
    self.editView = nil;
    [self setAgeInfoLabel:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIDevice *currentDevice = [UIDevice currentDevice];
    _deviceInfoLabel.text = [NSString stringWithFormat:@"设备：%@ 系统：%@", currentDevice.localizedModel, currentDevice.systemVersion];
    
    CGRect frame = _editBackgroundView.frame;
    frame.size.height = self.view.frame.size.height - frame.origin.y - KeyboardPortraitHeight - 10;
    _editBackgroundView.frame = frame;
    
    [_editView becomeFirstResponder];
}

#pragma mark - Private methods

- (void)ageRangeSelect {
    NSLog(@"ageRangeSelect");
}

- (void)close {
    [self dismissModalViewControllerAnimated:YES];
}

@end
