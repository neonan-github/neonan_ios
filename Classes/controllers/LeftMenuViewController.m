//
//  LeftMenuViewController.m
//  Neonan
//
//  Created by capricorn on 13-5-22.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "LeftMenuViewController.h"

#import "SideMenuCell.h"

@interface LeftMenuViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *searchBgView;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, readonly) NSArray *channelTexts;
@property (nonatomic, readonly) NSArray *channelTypes;

@end

@implementation LeftMenuViewController
@synthesize channelTexts = _channelTexts, channelTypes = _channelTypes;

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
    
    self.view.backgroundColor = DarkThemeColor;
    
    self.searchBgView.image = [[UIImage imageNamed:@"bg_search_bar"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 15, 10, 15)];
    
    UIImageView *firstSeparatorView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -2, CompatibleScreenWidth, 2)];
    firstSeparatorView.image = [UIImage imageFromFile:@"img_menu_separator.png"];
    [self.tableView addSubview:firstSeparatorView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cleanUp {
    [super cleanUp];
    
    self.searchBgView = nil;
    self.searchButton = nil;
    
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
    self.tableView = nil;
    
    _channelTexts = nil;
    _channelTypes = nil;
}

#pragma mark － UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.channelTexts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    SideMenuCell *cell = (SideMenuCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[SideMenuCell alloc] initWithReuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = self.channelTexts[indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.sidePanelController.centerPanel = self.sidePanelController.centerPanel;
    [self performSelector:@selector(changeController:) withObject:@(indexPath.row) afterDelay:0.2];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0;
}

#pragma mark - Private methods

- (NSArray *)channelTexts {
    if (!_channelTexts) {
        _channelTexts = @[@"首页", @"女人", @"知道", @"爱玩", @"视频"];
    }
    
    return  _channelTexts;
}

- (NSArray *)channelTypes {
    if (!_channelTypes) {
        _channelTypes = @[@"home", @"women", @"know", @"play", @"video"];
    }
    
    return _channelTypes;
}

- (void)changeController:(NSNumber *)index {
    NNContainerViewController *containerController = ((NeonanAppDelegate *)ApplicationDelegate).containerController;
    if (containerController.selectedIndex == index.integerValue) {
        return;
    }
    containerController.selectedIndex = index.integerValue;
}

@end
