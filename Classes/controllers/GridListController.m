//
//  GridListController.m
//  Neonan
//
//  Created by capricorn on 13-1-31.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "GridListController.h"
#import "TopicDetailController.h"

#import "TopicGridsModel.h"

#import "GridCell.h"

#import <MBProgressHUD.h>
#import <KKGridView.h>
#import <UIImageView+WebCache.h>

#import "UIScrollView+SVInfiniteScrolling.h"

@interface GridListController () <KKGridViewDataSource, KKGridViewDelegate>

@property (nonatomic, strong) TopicGridsModel *dataModel;

@property (nonatomic, unsafe_unretained) KKGridView *gridView;

@end

@implementation GridListController

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
    
    NNNavigationController *navController = (NNNavigationController *)self.navigationController;
//    navController.logoHidden = YES;
    
    UIButton* backButton = [UIHelper createBackButton:self.navigationController.navigationBar];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    self.view.backgroundColor = DarkThemeColor;
    
    KKGridView *gridView = self.gridView = [[KKGridView alloc] initWithFrame:CGRectMake(0, 0, CompatibleScreenWidth, CompatibleContainerHeight)];
    gridView.backgroundColor = [UIColor clearColor];
    gridView.cellSize = CGSizeMake(100.f, 100.f);
    gridView.cellPadding = CGSizeMake(5.f, 5.f);
    gridView.dataSource = self;
    gridView.delegate = self;
    [gridView addInfiniteScrollingWithActionHandler:^{
        [self requestData:_topicId withRequestType:RequestTypeAppend];
    }];
    gridView.infiniteScrollingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    [self.view addSubview:gridView];
}

- (void)cleanUp {
    self.gridView = nil;
    self.dataModel = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!_dataModel) {
        [self requestData:_topicId withRequestType:RequestTypeRefresh];
    }
}

#pragma mark - KKGridViewDataSource methods

- (NSUInteger)gridView:(KKGridView *)gridView numberOfItemsInSection:(NSUInteger)section {
    return _dataModel.items.count;
}

- (KKGridViewCell *)gridView:(KKGridView *)gridView cellForItemAtIndexPath:(KKIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    GridCell *cell = (GridCell *)[gridView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[GridCell alloc] initWithFrame:CGRectMake(0, 0, 100, 100) reuseIdentifier:cellIdentifier];
    }
    
    TopicItem *dataItem = _dataModel.items[indexPath.index];
    [cell setTitle:dataItem.name];
    [cell setRank:dataItem.ranking];
    [cell.imageView setImageWithURL:[NSURL URLWithString:dataItem.imageUrl] placeholderImage:[UIImage imageNamed:@"img_grid_place_holder.png"]];
    
    return cell;
}

#pragma mark - KKGridViewDelegate methods

- (void)gridView:(KKGridView *)gridView didSelectItemAtIndexPath:(KKIndexPath *)indexPath {
    TopicDetailController *controller = [[TopicDetailController alloc] init];
    TopicItem *dataItem = _dataModel.items[indexPath.index];
    controller.topicId = _topicId;
    controller.detailId = dataItem.contentId;
    controller.chName = dataItem.name;
    controller.rank = dataItem.ranking;
    controller.maxRank = _dataModel.totalCount;
    controller.title = self.title;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Private Request methods

- (void)requestData:(NSString *)contentId withRequestType:(RequestType)requestType {
    if (requestType == RequestTypeRefresh) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    NSUInteger offset = (requestType == RequestTypeRefresh ? 0 : [_dataModel items].count);
    
    NSDictionary *parameters = @{@"content_id" : contentId, @"offset" : @(offset), @"count" : @(30)};
    
    [[NNHttpClient sharedClient] getAtPath:kPathPeopleList parameters:parameters responseClass:[TopicGridsModel class] success:^(id<Jsonable> response) {
        if (requestType == RequestTypeAppend) {
            [self.dataModel appendMoreData:response];
        } else {
            self.dataModel = response;
        }
        
        [self performSelector:@selector(updateTableView:) withObject:@(requestType) afterDelay:0.3];
    } failure:^(ResponseError *error) {
        DLog(@"error:%@", error.message);
        if (requestType == RequestTypeRefresh) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
        
        if (self.isVisible) {
            [UIHelper alertWithMessage:error.message];
        }
        [_gridView.infiniteScrollingView stopAnimating];
    }];
    
}

#pragma mark - Private UI related

- (void)updateTableView:(NSNumber *)requestType {
    [_gridView reloadData];
    if (requestType.integerValue == RequestTypeAppend) {
        [_gridView.infiniteScrollingView stopAnimating];
    } else {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
    
    _gridView.showsInfiniteScrolling = [_dataModel totalCount] > [_dataModel items].count;
}

@end
