//
//  SearchResultViewController.m
//  Neonan
//
//  Created by capricorn on 13-6-6.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "SearchResultViewController.h"

#import "ChannelListViewCell.h"

#import "CommonListModel.h"

#import <UIImageView+WebCache.h>
#import <SVPullToRefresh.h>
#import <TTTAttributedLabel.h>

static NSString *const kSearchChannel = @"search";

@interface SearchResultViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, weak) UITextField *searchField;
@property (nonatomic, weak) UIButton *clearButton;

@property (nonatomic, weak) TTTAttributedLabel *resultLabel;
@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, strong) CommonListModel *dataModel;

@end

@implementation SearchResultViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = DarkThemeColor;
    
    [self configSearchField];
    
    UIButton *backButton = [UIHelper createBackButton:self.navigationController.navigationBar];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    TTTAttributedLabel *resultLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0, 0, CompatibleScreenWidth, 30)];
    self.resultLabel = resultLabel;
    resultLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    resultLabel.textInsets = UIEdgeInsetsMake(0, 8, 0, 0);
    resultLabel.backgroundColor = HEXCOLOR(0x232323);
    resultLabel.textColor = [UIColor whiteColor];
    resultLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:resultLabel];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 30, CompatibleScreenWidth, self.view.height - 30)
                                                          style:UITableViewStylePlain];
    self.tableView = tableView;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundView = nil;
    tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tableView];
    
    [tableView addPullToRefreshWithActionHandler:^{
        [self requestForList:kSearchChannel requestType:RequestTypeRefresh];
    }];
    tableView.pullToRefreshView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    
    [tableView addInfiniteScrollingWithActionHandler:^{
        [self requestForList:kSearchChannel requestType:RequestTypeAppend];
    }];
    tableView.infiniteScrollingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    tableView.showsInfiniteScrolling = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.dataModel) {
        [self.tableView triggerPullToRefresh];
    } else {
        [self.tableView reloadData];
    }
}

- (void)cleanUp {
    [super cleanUp];
    
    self.dataModel = nil;
    
    self.searchField.delegate = nil;
    self.searchField = nil;
    
    self.clearButton = nil;
    self.resultLabel = nil;
    
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
    self.tableView = nil;
}

#pragma mark － UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataModel.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    ChannelListViewCell *cell = (ChannelListViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[ChannelListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    CommonItem *dataItem = self.dataModel.items[indexPath.row];
    
    Record *record = [[Record alloc] init];
    record.contentId = dataItem.contentId;
    record.contentType = dataItem.contentType;
    
    cell.viewed = [[HistoryRecorder sharedRecorder] isRecorded:record];
    
    cell.tagImageView.image = [dataItem.contentType isEqualToString:@"video"] ? [UIImage imageNamed:@"icon_video_tag"] : nil;
    
    [cell.thumbnail setImageWithURL:[NSURL URLWithString:dataItem.thumbUrl]
                   placeholderImage:[UIImage imageNamed:@"img_placeholder_common.png"]];
    
    cell.titleLabel.text = dataItem.title;
    cell.dateLabel.text = dataItem.date;
    [cell setContentType:dataItem.contentType];
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CommonItem *dataItem = self.dataModel.items[indexPath.row];
    [(NeonanAppDelegate *)ApplicationDelegate navigationController:self.navigationController
                                          pushViewControllerByType:dataItem
                                                        andChannel:kSearchChannel];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0;
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

#pragma mark - Private Request methods

- (void)requestForList:(NSString *)channel requestType:(RequestType)requestType {
    NSUInteger offset = (requestType == RequestTypeRefresh ? 0 : [self.dataModel items].count);
    NSDictionary *parameters = @{@"channel": channel, @"sort_type": @"new", @"count": @(20),
                                 @"offset": @(offset), @"q": self.keyword};
    
    void (^done)() = ^{
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if (self.dataModel.totalCount && self.dataModel.items.count) {
                self.resultLabel.text = [NSString stringWithFormat:@"找到关于“%@”相关结果%d个", self.keyword, self.dataModel.totalCount];
            } else {
                self.resultLabel.text = [NSString stringWithFormat:@"抱歉，没有找到关于“%@”的相关结果", self.keyword];
            }
            
            [self updateTableView:requestType];
        });
    };
    
    [[NNHttpClient sharedClient] getAtPath:kPathWorkList
                                parameters:parameters
                             responseClass:[CommonListModel class]
                                   success:^(id<Jsonable> response) {
                                       if (requestType == RequestTypeAppend) {
                                           [self.dataModel appendMoreData:response];
                                       } else {
                                           self.dataModel = response;
                                       }
                                       
                                       done();
                                   } failure:^(ResponseError *error) {
                                       if (self.isVisible) {
                                           [UIHelper alertWithMessage:error.message];
                                       }
                                       
                                       done();
                                   }];
}

#pragma mark - Private Event Handle

- (void)clearSearchText {
    self.searchField.text = @"";
    self.clearButton.hidden = YES;
}

#pragma mark - Private methods

- (void)updateTableView:(RequestType)requestType {
    [self.tableView reloadData];
    
    if (requestType == RequestTypeRefresh) {
        [self.tableView.pullToRefreshView stopAnimating];
    } else {
        [self.tableView.infiniteScrollingView stopAnimating];
    }
    
    self.tableView.showsInfiniteScrolling = [self.dataModel totalCount] > [self.dataModel items].count;
}

- (void)configSearchField {
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 186, 40)];
    
    UIImageView *fieldBgView = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 186, 28)];
    fieldBgView.userInteractionEnabled = YES;
    fieldBgView.image = [[UIImage imageNamed:@"bg_search_bar"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 15, 10, 15)];
    
    UIImageView *searchIconView = [[UIImageView alloc] initWithFrame:CGRectMake(7, 7, 14, 14)];
    searchIconView.image = [UIImage imageFromFile:@"icon_search.png"];
    [fieldBgView addSubview:searchIconView];
    
    UITextField *searchField = [[UITextField alloc] initWithFrame:CGRectMake(24, 0, 132, 28)];
    self.searchField = searchField;
    searchField.placeholder = @"请输入关键词";
    searchField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    searchField.font = [UIFont systemFontOfSize:14];
    searchField.keyboardAppearance = UIKeyboardAppearanceAlert;
    searchField.returnKeyType = UIReturnKeySearch;
    searchField.delegate = self;
    searchField.text = self.keyword;
    [fieldBgView addSubview:searchField];
    
    [titleView addSubview:fieldBgView];
    
    UIButton *clearButton = [[UIButton alloc] initWithFrame:CGRectMake(157, 0, 40, 40)];
    self.clearButton = clearButton;
    clearButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [clearButton setImage:[UIImage imageFromFile:@"icon_clear.png"] forState:UIControlStateNormal];
    [clearButton addTarget:self action:@selector(clearSearchText) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:clearButton];
    
    self.navigationItem.titleView = titleView;
}

- (void)doSearch:(NSString *)text {
    if (!text || text.length < 1) {
        [UIHelper alertWithMessage:@"请输入要搜索的关键词"];
        return;
    }
    
    self.keyword = text;
    [self.searchField resignFirstResponder];
    [self.tableView triggerPullToRefresh];
}

@end
