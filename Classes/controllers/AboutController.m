//
//  AboutController.m
//  Neonan
//
//  Created by capricorn on 12-12-10.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "AboutController.h"

@interface AboutController ()

@property (unsafe_unretained, nonatomic) IBOutlet UITextView *descriptionView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *rightLabel;

@end

@implementation AboutController

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
    
    self.view.backgroundColor = DarkThemeColor;
    
    _descriptionView.text = [NSString stringWithFormat:_descriptionView.text, [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    _rightLabel.text = @"牛朝（上海）信息科技有限公司 版权所有\nCopyright © 2012 牛男NEO.com Inc.\nAll Rights Reserved.";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)close {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload {
    self.rightLabel = nil;
    self.descriptionView = nil;
    [super viewDidUnload];
}
@end
