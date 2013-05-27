//
//  LeftMenuViewController.m
//  Neonan
//
//  Created by capricorn on 13-5-22.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "LeftMenuViewController.h"

@interface LeftMenuViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *searchBgView;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation LeftMenuViewController

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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cleanUp {
    [super cleanUp];
    
    self.searchBgView = nil;
    self.searchButton = nil;
    self.tableView = nil;
}

@end
