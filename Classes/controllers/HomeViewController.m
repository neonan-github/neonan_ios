//
//  HomeViewController.m
//  Neonan
//
//  Created by capricorn on 13-5-23.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "HomeViewController.h"

#import "NNButton.h"
#import "HomeGridViewCell.h"

#import "MainSlideShowModel.h"
#import "CommentListModel.h"

#import <SwipeView.h>
#import <KKGridView.h>
#import <TTTAttributedLabel.h>
#import <UIImageView+WebCache.h>
#import <UIButton+WebCache.h>
#import <UIImage+Filtering.h>
#import <SVPullToRefresh.h>

static const NSInteger kPageCount = 6;
static const NSInteger kItemPerPageCount = 6;

static const NSInteger kTagHeaderImageView = 1000;
static const NSInteger kTagHeaderLabel = 1001;

@interface HomeViewController () <SwipeViewDelegate, SwipeViewDataSource,
KKGridViewDataSource, KKGridViewDelegate>

@property (weak, nonatomic) IBOutlet SwipeView *swipeView;

@property (nonatomic, assign) NSInteger currentPageIndex;

@end

@implementation HomeViewController

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
    
    self.view.backgroundColor = HEXCOLOR(0x171717);
    
    self.swipeView.dataSource = self;
    self.swipeView.delegate = self;
    
    self.currentPageIndex = self.swipeView.currentPage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cleanUp {
    [super cleanUp];
    
    self.swipeView.dataSource = nil;
    self.swipeView.delegate = nil;
    self.swipeView = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.swipeView reloadData];
}

#pragma mark - SwipeViewDataSource methods

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView {
    return kPageCount;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    KKGridView *gridView = (KKGridView *)view;
    
    if (!view) {   
        gridView = [[KKGridView alloc] initWithFrame:CGRectMake(0, 0, CompatibleScreenWidth, CompatibleContainerHeight)];
        gridView.backgroundColor = [UIColor clearColor];
        gridView.dataSource = self;
        gridView.delegate = self;
        gridView.cellSize = CGSizeMake(145.0, 116.0);
        gridView.cellPadding = CGSizeMake(10, 10);
        gridView.gridHeaderView = [self createHeaderView];
        gridView.gridFooterView = [self createFooterView];
        
        [gridView addPullToRefreshWithActionHandler:^{
            
        }];
    }
    
    KKGridView *currentPageView = ((KKGridView *)[swipeView itemViewAtIndex:self.currentPageIndex]);
    
    gridView.tag = index;
    gridView.gridHeaderView.tag = index;
    gridView.contentOffset = currentPageView.contentOffset;
    [gridView reloadData];
    
    return gridView;
}

#pragma mark - SwipeViewDelegate methods

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView {
    self.currentPageIndex = swipeView.currentPage;
}

#pragma mark - KKGridViewDataSource methods

- (NSUInteger)gridView:(KKGridView *)gridView numberOfItemsInSection:(NSUInteger)section {
    return kItemPerPageCount;
}

- (KKGridViewCell *)gridView:(KKGridView *)gridView cellForItemAtIndexPath:(KKIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    HomeGridViewCell * cell = (HomeGridViewCell *)[gridView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[HomeGridViewCell alloc] initWithFrame:CGRectMake(0.0, 0.0, 145.0, 116.0) reuseIdentifier:CellIdentifier];
    }
    
    cell.titleLabel.text = @"跳绳快速运动减肥法的好处";
    
    __weak HomeGridViewCell *weakCell = cell;
    [cell.imageView setImageWithURL:[NSURL URLWithString:@"http://cdn.neonan.com/uploads/d8c0a3e4-bded-47e9-aa4d-baf69156e9af.jpg_300"]
                            success:^(UIImage *image, BOOL cached) {
                                weakCell.imageView.highlightedImage = [image opacity:0.8];
                            } failure:^(NSError *error) {
                                
                            }];
    
    return cell;
}

#pragma mark - KKGridViewDelegate methods

- (void)gridView:(KKGridView *)gridView didSelectItemAtIndexPath:(KKIndexPath *)indexPath {
    [gridView deselectItemsAtIndexPaths:@[indexPath] animated:YES];
    
    if (self.swipeView.isDragging) {
        return;
    }
    
    DLog(@"select at: %d", gridView.tag * kItemPerPageCount + indexPath.index);
}

#pragma mark - Private Event Handle

- (void)onHeaderViewClicked:(id)sender {
    DLog(@"onHeaderViewClicked: %d", [sender tag]);
}

#pragma mark - Private Request methods

- (void)requestForSlideShow {
    NSDictionary *parameters = @{@"channel": @"home", @"count": @(6)};
    
    [[NNHttpClient sharedClient] getAtPath:kPathSlideShow
                                parameters:parameters
                             responseClass:[MainSlideShowModel class]
                                   success:^(id<Jsonable> response) {
                                   }
                                   failure:^(ResponseError *error) {
                                   }];
}

- (void)requestForList {
    NSDictionary *parameters = @{@"channel": @"home", @"sort_type": @"new", @"count": @(36),
                                 @"offset": @(0)};
    
    [[NNHttpClient sharedClient] getAtPath:kPathWorkList
                                parameters:parameters
                             responseClass:[CommentListModel class]
                                   success:^(id<Jsonable> response) {
                                   }
                                   failure:^(ResponseError *error) {
                                   }];
}

#pragma mark - Private methods

- (UIView *)createHeaderView {
    NNButton *headerView = [[NNButton alloc] initWithFrame:CGRectMake(0, 0, CompatibleScreenWidth, 182)];
    [headerView addTarget:self action:@selector(onHeaderViewClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 300, 166)];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.backgroundColor = [UIColor blackColor];
    imageView.tag = kTagHeaderImageView;
    
    __weak UIImageView *weakImageView = imageView;
    [imageView setImageWithURL:[NSURL URLWithString:@"http://cdn.neonan.com/uploads/4684cf45-f8e6-4fab-bc6f-1728aac7fbb8.jpg_680"]
              placeholderImage:nil
                       success:^(UIImage *image, BOOL cached) {
                           weakImageView.highlightedImage = [image opacity:0.8];
                       }
                       failure:^(NSError *error) {
        
                       }];
    [headerView addSubview:imageView];
    
    TTTAttributedLabel *label = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(10, 177 - 28, 300, 28)];
    label.textInsets = UIEdgeInsetsMake(0, 8, 0, 0);
    label.clipsToBounds = YES;
    label.font = [UIFont systemFontOfSize:16];
    label.highlightedTextColor = [UIColor lightTextColor];
    label.textColor = [UIColor whiteColor];
    label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    label.backgroundColor = RGBA(0, 0, 0, 0.5);
    label.tag = kTagHeaderLabel;
    
    CALayer *bottomLineLayer = [CALayer layer];
    bottomLineLayer.frame = CGRectMake(0, 27, 300, 1);
    bottomLineLayer.backgroundColor = HEXCOLOR(0x0096ff).CGColor;
    [label.layer addSublayer:bottomLineLayer];
    
    label.text = @"请掌握穷变富的原则top 10";
    [headerView addSubview:label];
    
    return headerView;
}

- (UIView *)createFooterView {
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, CompatibleScreenWidth, 5)];
}

@end
