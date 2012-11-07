//
//  MainController.m
//  Neonan
//
//  Created by capricorn on 12-10-22.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "MainController.h"
#import "NNNavigationController.h"
#import "BabyDetailController.h"
#import "ArticleDetailController.h"
#import "VideoPlayController.h"

#import "SMPageControl.h"
#import "HotListCell.h"
#import "BabyCell.h"
#import "CircleHeaderView.h"
#import "SlideShowView.h"
#import "CustomNavigationBar.h"
#import <SVPullToRefresh.h>
#import <TTTAttributedLabel.h>
#import <NYXImagesKit.h>

#import "BabyDetailController.h"
#import "CommentListController.h"

#import "ListCellModel.h"
#import "BabyCellModel.h"

typedef enum {
    listTypeLatest = 0,
    listTypeHotest
} listType;

@interface MainController () <BabyCellDelegate, SDWebImageManagerDelegate>
@property (nonatomic, unsafe_unretained) UIButton *navLeftButton;
@property (nonatomic, unsafe_unretained) UIButton *navRightButton;
@property (nonatomic, unsafe_unretained) SlideShowView *slideShowView;
@property (nonatomic, unsafe_unretained) SMPageControl *pageControl;
@property (nonatomic, unsafe_unretained) UITableView *tableView;
@property (nonatomic, unsafe_unretained) CircleHeaderView *headerView;

@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, assign) listType type;

@property (nonatomic, strong) NSMutableArray *listData;

- (UITableViewCell *)createHotListCell:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)createBabyCell:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSString *)stringForType:(listType)type;
@end

@implementation MainController
@synthesize slideShowView = _slideShowView, pageControl = _pageControl, tableView = _tableView,
headerView = _headerView;
@synthesize images = _images, titles = _titles;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UIButton *navLeftButton = self.navLeftButton = [UIHelper createBarButton:0];
    [navLeftButton setImage:[UIImage imageFromFile:@"icon_user_normal.png"] forState:UIControlStateNormal];
    UIImage *userHighlightedImage = [UIImage imageFromFile:@"icon_user_highlighted.png"];
    [navLeftButton setImage:userHighlightedImage forState:UIControlStateHighlighted];
    [navLeftButton setImage:userHighlightedImage forState:UIControlStateSelected];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navLeftButton];
    
    UIButton *navRightButton = self.navRightButton = [UIHelper createBarButton:5];
    [navRightButton setTitle:[self stringForType:_type] forState:UIControlStateNormal];
    [navRightButton addTarget:self action:@selector(switchListType) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navRightButton];
    
    float layoutY = 0;
    
    CircleHeaderView *headerView = self.headerView = [[CircleHeaderView alloc] initWithFrame:CGRectMake(0, layoutY, CompatibleScreenWidth, 30)];
    headerView.delegate = self;
    headerView.titles = self.titles = [[NSArray alloc] initWithObjects:@"性情", @"生活", @"主页", @"财富", @"玩乐", @"宝贝", nil];
    [headerView reloadData];
    [self.view addSubview:headerView];
    
    layoutY += 30;
    SlideShowView *slideShowView = self.slideShowView = [[SlideShowView alloc] initWithFrame:CGRectMake(0, layoutY, CompatibleScreenWidth, 120)];
    slideShowView.dataSource = self;
    slideShowView.delegate = self;
    [self.view addSubview:slideShowView];
    
    TTTAttributedLabel *slideShowTextLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0, layoutY + 120 - 16, CompatibleScreenWidth, 16)];
    slideShowTextLabel.textInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    slideShowTextLabel.clipsToBounds = YES;
    slideShowTextLabel.font = [UIFont systemFontOfSize:8];
    slideShowTextLabel.textColor = [UIColor whiteColor];
    slideShowTextLabel.text = @"绅士必备 木质调香水最佳推荐";
    slideShowTextLabel.backgroundColor = RGBA(6, 6, 6, 0.7);
    [self.view addSubview:slideShowTextLabel];
    
    SMPageControl *pageControl = self.pageControl = [[SMPageControl alloc] initWithFrame:CGRectMake(0, layoutY + 120 - 16, CompatibleScreenWidth - 10, 16)];
    pageControl.indicatorDiameter = 5;
    pageControl.indicatorMargin = 4;
    pageControl.currentPageIndicatorTintColor = HEXCOLOR(0x00a9ff);
    pageControl.alignment = SMPageControlAlignmentRight;
    pageControl.userInteractionEnabled = NO;
    [self.view addSubview:pageControl];
    
    layoutY += 120;
    UITableView *tableView = self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, layoutY, CompatibleScreenWidth, CompatibleContainerHeight - layoutY) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = DarkThemeColor;
    [tableView addPullToRefreshWithActionHandler:^{
        // refresh data
        // call [tableView.pullToRefreshView stopAnimating] when done
    }];
    [tableView addInfiniteScrollingWithActionHandler:^{
        // add data to data source, insert new cells into table view
    }];
    [self.view addSubview:tableView];
    
    self.images = [[NSArray alloc] initWithObjects:@"http://neonan.b0.upaiyun.com/uploads/7ba32007-fa1c-4625-9c03-8607c3468ec7.jpg",
                   @"http://neonan.b0.upaiyun.com/uploads/a78299ad-8972-4224-ac7f-9c9a88d34564.jpg",
                   @"http://neonan.b0.upaiyun.com/uploads/96b12b06-0925-4579-b069-747ea154f18c.jpg",
                   @"http://neonan.b0.upaiyun.com/uploads/e9873bfb-f865-4a49-a815-56f2b7bbf641.jpg",
                   @"http://neonan.b0.upaiyun.com/uploads/d8380d5b-7153-4ea0-9bd6-d53a3ee38db1.jpg",
                   @"http://neonan.b0.upaiyun.com/uploads/d615d555-67e3-4f86-a8e3-d3b77888ca64.jpg", nil];
    
    self.listData = [[NSMutableArray alloc] initWithCapacity:20];
    for (NSUInteger i = 0; i < 20; i++) {
        [self.listData addObject:[[BabyCellModel alloc] init]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cleanUp
{
    self.navLeftButton = nil;
    self.navRightButton = nil;
    
    self.slideShowView.delegate = nil;
    self.slideShowView.dataSource = nil;
    self.slideShowView = nil;
    
    self.pageControl = nil;
    
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    self.tableView = nil;
    
    self.headerView.delegate = nil;
    self.headerView = nil;
}

- (void)viewDidUnload
{
    [self cleanUp];
    [super viewDidUnload];
}

- (void)dealloc
{
    [self cleanUp];
}

- (void)setType:(listType)type {
    if (_type != type) {
        _type = type;
        [self.navRightButton setTitle:[self stringForType:type] forState:UIControlStateNormal];
    }
}

#pragma mark - UIViewController life cycle
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.slideShowView reloadData];
    [self.slideShowView startAutoScroll:2];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.slideShowView stopAutoScroll];
    
    [super viewWillDisappear:animated];
}


#pragma mark - SlideShowViewDataSource methods

- (NSUInteger)numberOfItemsInSlideShowView:(SlideShowView *)slideShowView {
    NSUInteger count = self.images.count;
    [self.pageControl setNumberOfPages:count];
    return count;
}

- (UIView *)slideShowView:(SlideShowView *)slideShowView viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    if (!view) {
        view = [[UIImageView alloc] init];
//        view.clipsToBounds = NO;
//        view.contentMode = UIViewContentModeScaleAspectFill;
    }
    
//    [((UIImageView *)view) setImageWithURL:[NSURL URLWithString:[self.images objectAtIndex:index]]];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadWithURL:[self.images objectAtIndex:index]
                    delegate:self
                     options:0
                     success:^(UIImage *image, BOOL cached)
     {
         UIImage *cropedImage = [[image scaleByFactor:view.frame.size.width / image.size.width] cropToSize:view.frame.size usingMode:NYXCropModeTopCenter];
         [((UIImageView *)view) setImage:cropedImage];
     }
                     failure:nil];
    
    return view;
}

#pragma mark - SlideShowViewDelegate methods

- (void)slideShowViewItemIndexDidChange:(SlideShowView *)slideShowView {
    [self.pageControl setCurrentPage:slideShowView.carousel.currentItemIndex];
}

#pragma mark － UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _listData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.headerView.carousel.currentItemIndex == 0) {
        return [self createBabyCell:tableView forRowAtIndexPath:indexPath];
    }
    
    return [self createHotListCell:tableView forRowAtIndexPath:indexPath];
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.headerView.carousel.currentItemIndex == 0 ? 80 : 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *controller;
    switch (indexPath.row % 2) {
        case 0:
            controller = [[ArticleDetailController alloc] init];
            break;
            
        default:
            controller = [[BabyDetailController alloc] init];
            break;
    }
    [self.navigationController pushViewController:controller animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - CircleHeaderViewDelegate methods

- (void)currentItemIndexDidChange:(CircleHeaderView *)headView {
    self.listData = nil;
    [_slideShowView reloadData];
    [_tableView reloadData];
}

#pragma mark - BabyCellDelegate methods

- (void)playVideoAtIndex:(NSUInteger)index {
    UIViewController *controller = [[VideoPlayController alloc] init];
    NNNavigationController *navController = [[NNNavigationController alloc] initWithRootViewController:controller];
    [self.navigationController presentModalViewController:navController animated:YES];
}

#pragma mark - Private methods

- (UITableViewCell *)createHotListCell:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *listCellIdentifier = @"HotListCell";
    
    HotListCell *cell = [tableView dequeueReusableCellWithIdentifier:listCellIdentifier];
    if (!cell) {
        cell = [[HotListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:listCellIdentifier];
    }
    
    ListCellModel *model = [_listData objectAtIndex:indexPath.row];
    [cell.thumbnail setImageWithURL:[NSURL URLWithString:model.imgUrl]];
    cell.titleLabel.text = model.title;
    cell.descriptionLabel.text = model.category;
    cell.dateLabel.text = model.date;
    
    return cell;
}

- (UITableViewCell *)createBabyCell:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath  {
    static NSString *babyCellIdentifier = @"BabyCell";
    
    BabyCell *cell = [tableView dequeueReusableCellWithIdentifier:babyCellIdentifier];
    if (!cell) {
        cell = [[BabyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:babyCellIdentifier];
        cell.delegate = self;
    }
    
    BabyCellModel *model = [_listData objectAtIndex:indexPath.row];
    [cell.thumbnail setImageWithURL:[NSURL URLWithString:model.babyImgUrl]];
    cell.titleLabel.text = model.title;
    cell.scoreLabel.text = [NSString stringWithFormat:@"%u票", model.score];
    cell.videoShots = model.shotImgUrls;
 
    return cell;
}

- (NSString *)stringForType:(listType)type {
    if (type == listTypeLatest) {
        return @"最新";
    }

    return @"最热";
}

- (void)switchListType {
    listType newType = _type == listTypeLatest ? listTypeHotest : listTypeLatest;
    self.type = newType;
}

@end
