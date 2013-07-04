//
//  LeftMenuViewController.m
//  Neonan
//
//  Created by capricorn on 13-5-22.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "LeftMenuViewController.h"
#import "SearchResultViewController.h"
#import "ChannelListViewController.h"

#import "SideMenuCell.h"

#import <UIAlertView+Blocks.h>

@interface LeftMenuViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, assign) NSInteger selectedIndex;

@property (weak, nonatomic) IBOutlet UIImageView *searchBgView;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, readonly) NSArray *channelTexts;
@property (nonatomic, readonly) NSArray *channelTypes;
@property (nonatomic, readonly) NSArray *channelIcons;
@property (nonatomic, strong) NSArray *videoSubChannelTypes;
@property (nonatomic, strong) NSArray *videoSubChannelTexts;

@end

@implementation LeftMenuViewController
@synthesize channelTexts = _channelTexts, channelTypes = _channelTypes, channelIcons = _channelIcons;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.selectedIndex = -1;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = HEXCOLOR(0x121212);
    
    self.searchBgView.image = [[UIImage imageNamed:@"bg_search_bar"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 15, 10, 15)];
    
    self.clearButton.hidden = _searchField.text.length < 1;
    [self.clearButton addTarget:self action:@selector(clearSearchText) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *firstSeparatorView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -2, CompatibleScreenWidth, 2)];
    firstSeparatorView.image = [UIImage imageFromFile:@"img_menu_separator.png"];
    [self.tableView addSubview:firstSeparatorView];
    
    self.selectedIndex = self.selectedIndex < 0 ? ((NeonanAppDelegate *)ApplicationDelegate).containerController.selectedIndex : self.selectedIndex;
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex inSection:0]
                                animated:NO
                          scrollPosition:UITableViewScrollPositionNone];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cleanUp {
    [super cleanUp];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.searchBgView = nil;
    self.searchButton = nil;
    
    self.searchField.delegate = nil;
    self.searchField = nil;
    
    self.clearButton = nil;
    
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
    self.tableView = nil;
    
    _channelTexts = nil;
    _channelTypes = nil;
}

#pragma mark － UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.channelTexts.count + self.videoSubChannelTexts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    SideMenuCell *cell = (SideMenuCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[SideMenuCell alloc] initWithReuseIdentifier:cellIdentifier];
    }
    
    NSUInteger row = indexPath.row;
    NSUInteger channelCount = self.channelTexts.count;
    BOOL isSubChannel = row >= channelCount;
    
    cell.imageView.image = isSubChannel ? nil : [UIImage imageNamed:self.channelIcons[row]];
    cell.textLabel.text = isSubChannel ? self.videoSubChannelTexts[row - channelCount] : self.channelTexts[row];
    ((UIImageView *)cell.backgroundView).image = [[UIImage imageFromFile:isSubChannel ? @"bg_menu_cell.png" : @"bg_menu_1level_cell.png"]
                                                  resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 1, 0)];

    
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

#pragma mark - UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.clearButton.hidden = textField.text.length < 1;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    self.clearButton.hidden = newText.length < 1;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self doSearch:[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    return YES;
}

#pragma mark - Private Event Handle

- (void)keyboardWillShow:(NSNotification *)note {
    
}

- (void)keyboardWillHide:(NSNotification *)note {
}

- (void)keyboardDidHide:(NSNotification *)note {
    [self clearSearchText];
    [self.searchField resignFirstResponder];
}

- (void)clearSearchText {
    self.searchField.text = @"";
    self.clearButton.hidden = YES;
}

#pragma mark - Private methods

- (NSArray *)channelTexts {
    if (!_channelTexts) {
        _channelTexts = [(NeonanAppDelegate *)ApplicationDelegate contentLocked] ?
                        @[@"精选", @"知道", @"爱玩", @"牛男TV"] :
                        @[@"精选", @"女人", @"知道", @"爱玩", @"牛男TV"];
    }
    
    return  _channelTexts;
}

- (NSArray *)channelTypes {
    if (!_channelTypes) {
        _channelTypes = [(NeonanAppDelegate *)ApplicationDelegate contentLocked] ?
                        @[@"home", @"know", @"play", @"video"] :
                        @[@"home", @"women", @"know", @"play", @"video"];
    }
    
    return _channelTypes;
}

- (NSArray *)channelIcons {
    if (!_channelIcons) {
        _channelIcons = [(NeonanAppDelegate *)ApplicationDelegate contentLocked] ?
                        @[@"icon_menu_top", @"icon_menu_know", @"icon_menu_play", @"icon_menu_video"] :
                        @[@"icon_menu_top", @"icon_menu_women", @"icon_menu_know", @"icon_menu_play", @"icon_menu_video"];
    }
    
    return _channelIcons;
}

- (NSArray *)videoSubChannelTypes {
    if (!_videoSubChannelTypes) {
        _videoSubChannelTypes = [(NeonanAppDelegate *)ApplicationDelegate contentLocked] ?
                                @[@"car", @"outdoor", @"gadget", @"game", @"money"] :
                                @[@"car", @"outdoor", @"sexy", @"gadget", @"game", @"money", @"babes"];
    }
    
    return _videoSubChannelTypes;
}

- (NSArray *)videoSubChannelTexts {
    if (!_videoSubChannelTexts) {
        _videoSubChannelTexts = [(NeonanAppDelegate *)ApplicationDelegate contentLocked] ?
                                @[@"酷车世界", @"户外健身", @"科技玩物", @"火爆游戏", @"财富励志"] :
                                @[@"酷车世界", @"户外健身", @"性感地带", @"科技玩物", @"火爆游戏", @"财富励志", @"牛男宝贝"];
    }
    
    return _videoSubChannelTexts;
}

- (void)changeController:(NSNumber *)indexNumber {
    NSInteger index = indexNumber.integerValue;
    
    if (self.selectedIndex == index) {
        return;
    }
    
    BOOL isVideoChannel = index >= self.channelTypes.count - 1;
    NNContainerViewController *containerController = ((NeonanAppDelegate *)ApplicationDelegate).containerController;
    if (isVideoChannel && self.selectedIndex >= self.channelTypes.count - 1) {
    } else {
        containerController.selectedIndex = MIN(self.channelTypes.count - 1, index);
    }
    
    if (isVideoChannel) {
        NSString *title = index == self.channelTypes.count - 1 ? @"牛男TV" : self.videoSubChannelTexts[index - self.channelTypes.count];
        NSString *subChannel = index == self.channelTypes.count - 1 ? nil : self.videoSubChannelTypes[index - self.channelTypes.count];
        DLog(@"subChannel %@", subChannel);
        ChannelListViewController *viewController = (ChannelListViewController *)[(NNNavigationController *)containerController.currentViewController topViewController];
        viewController.title = title;
        viewController.subChannel = subChannel;
    }
    
    self.selectedIndex = index;
}

- (void)doSearch:(NSString *)text {
    if (!text || text.length < 1) {
        [UIHelper alertWithMessage:@"请输入要搜索的关键词"];
        return;
    }
    
    self.sidePanelController.centerPanel = self.sidePanelController.centerPanel;
    
    NNNavigationController *topNavController = (NNNavigationController *)((NeonanAppDelegate *)ApplicationDelegate).containerController.currentViewController;
    SearchResultViewController *viewController = [[SearchResultViewController alloc] init];
    viewController.keyword = text;
    [topNavController pushViewController:viewController animated:NO];
}

@end
