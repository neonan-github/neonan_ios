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
    UIButton *navLeftButton = [UIHelper createLeftBarButton:@"icon_close_normal.png"];
    [navLeftButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navLeftButton];
    
    self.view.backgroundColor = DarkThemeColor;
    
    _descriptionView.text = [NSString stringWithFormat:_descriptionView.text, [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    _rightLabel.text = @"牛朝（上海）信息科技有限公司 版权所有\nCopyright © 2012 牛男NEO.com Inc.\nAll Rights Reserved.";
}

- (void)cleanUp {
    self.rightLabel = nil;
    self.descriptionView = nil;
}

- (void)close {
    [self dismissModalViewControllerAnimated:YES];
}

@end
