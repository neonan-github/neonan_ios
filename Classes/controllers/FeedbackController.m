//
//  FeedbackController.m
//  Neonan
//
//  Created by capricorn on 12-12-11.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "FeedbackController.h"
#import "UMFeedback.h"

#import <MBProgressHUD.h>
#import <ActionSheetStringPicker.h>

#import <SSTextView.h>

@interface FeedbackController () <UMFeedbackDataDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *deviceInfoLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *editBackgroundView;
@property (unsafe_unretained, nonatomic) IBOutlet SSTextView *editView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *ageInfoLabel;

@property (nonatomic, assign) NSInteger ageIndex;

@property (nonatomic, strong) UMFeedback *umFeedback;

@end

@implementation FeedbackController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.ageIndex = -1;
    }
    return self;
}

- (UMFeedback *)umFeedback {
    if (!_umFeedback) {
        _umFeedback = [UMFeedback sharedInstance];
        [_umFeedback setAppkey:UMengAppKey delegate:self];
    }
    
    return _umFeedback;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"意见反馈";
    
    UIButton *navLeftButton = [UIHelper createLeftBarButton:@"icon_nav_close.png"];
    [navLeftButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navLeftButton];
    
    UIButton *navRightButton = [UIHelper createLeftBarButton:@"icon_nav_done.png"];
    [navRightButton addTarget:self action:@selector(commit) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navRightButton];
    
    self.view.backgroundColor = DarkThemeColor;
    
    UIImage *editBgImage = [[UIImage imageFromFile:@"bg_feedback_edit.png"] stretchableImageWithLeftCapWidth:27 topCapHeight:15];
    [_editBackgroundView setImage:editBgImage];
    
    _editView.placeholder = @"请输入反馈，限250字";
    
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

- (void)cleanUp {
    self.deviceInfoLabel = nil;
    self.editBackgroundView = nil;
    self.editView = nil;
    [self setAgeInfoLabel:nil];
}

- (void)dealloc {
    _umFeedback.delegate = nil;
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

#pragma mark - UMFeedbackDataDelegate methods

- (void)postFinishedWithError:(NSError *)error {
    [MBProgressHUD hideAllHUDsForView:_editView animated:YES];
    
    [UIHelper alertWithMessage:[NSString stringWithFormat:@"提交%@", !error ? @"成功" : @"失败"]];
}

#pragma mark - Private methods

- (void)ageRangeSelect {
    ActionSheetStringPicker *ageSelectSheet = [[ActionSheetStringPicker alloc] initWithTitle:@""
                                                                rows:@[@"小于18岁", @"18～24岁", @"25～30岁", @"31～35岁", @"36～40岁", @"41～50岁", @"51～59岁", @"大于60岁"]
                                                    initialSelection:MAX(_ageIndex, 0)
                                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                                               self.ageIndex = selectedIndex;
                                                               _ageInfoLabel.text = [NSString stringWithFormat:@"年龄：%@", selectedValue];
                                                           }
                                                         cancelBlock:^(ActionSheetStringPicker *picker) {
                                                         } origin:_ageInfoLabel];
    
    [ageSelectSheet showActionSheetPicker];
}

- (void)close {
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)checkContent:(NSString *)content {
    if (!content || content.length < 1 || content.length > 250 ) {
        return NO;
    }
    
    return YES;
}

- (void)commit {
    if (![self checkContent:_editView.text]) {
        [UIHelper alertWithMessage:@"输入内容有误，请检查"];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:_editView animated:YES];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:_editView.text forKey:@"content"];
    if (_ageIndex >= 0) {
        [dictionary setObject:@(_ageIndex + 1) forKey:@"age_group"];
    }
    [self.umFeedback post:dictionary];
}

@end
