//
//  AboutController.m
//  Neonan
//
//  Created by capricorn on 12-12-10.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@property (unsafe_unretained, nonatomic) IBOutlet UITextView *descriptionView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *rightLabel;

@end

@implementation AboutViewController

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
    self.title = @"关于我们";
    
    UIButton *backButton = [UIHelper createBackButton:self.navigationController.navigationBar];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    self.view.backgroundColor = DarkThemeColor;
    
    _descriptionView.text = [NSString stringWithFormat:_descriptionView.text, [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    _rightLabel.text = @"牛朝（上海）信息科技有限公司 版权所有\nCopyright © 2012 牛男NEO.com Inc.\nAll Rights Reserved.";
}

- (void)cleanUp {
    self.rightLabel = nil;
    self.descriptionView = nil;
}

@end
