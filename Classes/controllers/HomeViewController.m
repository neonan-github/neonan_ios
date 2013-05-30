//
//  HomeViewController.m
//  Neonan
//
//  Created by capricorn on 13-5-23.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "HomeViewController.h"
#import "ArticleDetailController.h"
#import "GalleryDetailController.h"
#import "VideoPlayController.h"

#import "NNButton.h"
#import "HomeGridViewCell.h"

#import "MainSlideShowModel.h"
#import "CommonListModel.h"

#import <SwipeView.h>
#import <KKGridView.h>
#import <TTTAttributedLabel.h>
#import <UIImageView+WebCache.h>
#import <UIButton+WebCache.h>
#import <UIImage+Filtering.h>
#import <MBProgressHUD.h>

static const NSInteger kPageCount = 6;
static const NSInteger kItemPerPageCount = 6;

static const NSInteger kTagHeaderImageView = 1000;
static const NSInteger kTagHeaderLabel = 1001;

static NSString *const kHeaderBottomLineName = @"bottomLine";
static NSString *const kLastUpdateKey = @"home_last_update";

@interface HomeViewController () <SwipeViewDelegate, SwipeViewDataSource,
KKGridViewDataSource, KKGridViewDelegate>

@property (weak, nonatomic) IBOutlet SwipeView *swipeView;

@property (nonatomic, assign) NSInteger currentPageIndex;

@property (nonatomic, strong) MainSlideShowModel *slideShowModel;
@property (nonatomic, strong) CommonListModel *listDataModel;
@property (nonatomic, strong) ResponseError *responseError;

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
    
    self.view.backgroundColor = DarkThemeColor;
    
    self.navigationItem.titleView = [UIHelper createLogoView];
    
    UIButton *navLeftButton = [UIHelper createLeftBarButton:@"icon_menu_normal.png"];
    [navLeftButton addTarget:self action:@selector(showLeftPanel) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navLeftButton];
    
    UIButton *navRightButton = [UIHelper createLeftBarButton:@"icon_nav_account.png"];
    [navRightButton addTarget:self action:@selector(showRightPanel) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navRightButton];
    
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
    
    self.slideShowModel = nil;
    self.listDataModel = nil;
    self.responseError = nil;
    
    self.swipeView.dataSource = nil;
    self.swipeView.delegate = nil;
    self.swipeView = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSDate *lastUpdateDate = [NSDate dateWithTimeIntervalSince1970:[UserDefaults integerForKey:kLastUpdateKey]];
    if (!self.slideShowModel || !self.listDataModel ||
        [[NSDate date] timeIntervalSinceDate:lastUpdateDate] > 10 * kMinuteSeconds) {
        [self requestData];
    }
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
    }
    
    KKGridView *currentPageView = ((KKGridView *)[swipeView itemViewAtIndex:self.currentPageIndex]);
    
    gridView.tag = index;
    gridView.gridHeaderView.tag = index;
    gridView.contentOffset = currentPageView.contentOffset;
    
    CALayer *headerBottomLineLayer = [UIHelper layerWithName:kHeaderBottomLineName
                                                      inView:[gridView.gridHeaderView viewWithTag:kTagHeaderLabel]];
    CGRect frame = headerBottomLineLayer.frame;
    frame.size.width = 50 * (index + 1);
    headerBottomLineLayer.frame = frame;
    
    [self fillDataInHeaderView:gridView.gridHeaderView];
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
    
    CommonItem *model = !self.listDataModel ? nil : self.listDataModel.items[gridView.tag * kItemPerPageCount + indexPath.index];
    
    cell.titleLabel.text = model.title;
    
    __weak HomeGridViewCell *weakCell = cell;
    [cell.imageView setImageWithURL:[NSURL URLWithString:model.thumbUrl]
                            success:^(UIImage *image, BOOL cached) {
                                weakCell.imageView.highlightedImage = [image opacity:0.8];
                            } failure:^(NSError *error) {
                                
                            }];
    
    return cell;
}

#pragma mark - KKGridViewDelegate methods

- (void)gridView:(KKGridView *)gridView didSelectItemAtIndexPath:(KKIndexPath *)indexPath {
    [gridView deselectItemsAtIndexPaths:@[indexPath] animated:YES];
    
    if (self.swipeView.isDragging || !self.listDataModel) {
        return;
    }
    
    NSInteger index = gridView.tag * kItemPerPageCount + indexPath.index;
    [(NeonanAppDelegate *)ApplicationDelegate navigationController:self.navigationController
                                          pushViewControllerByType:self.listDataModel.items[index]
                                                        andChannel:@"home"];
}

#pragma mark - Private Event Handle

- (void)onHeaderViewClicked:(id)sender {
    if (!self.slideShowModel) {
        return;
    }
    
    [(NeonanAppDelegate *)ApplicationDelegate navigationController:self.navigationController
                                          pushViewControllerByType:self.slideShowModel.list[[sender tag]]
                                                        andChannel:@"home"];
}

#pragma mark - Private Request methods

- (void)requestForSlideShow:(NSString *)channel success:(void (^)())success failure:(void (^)())failure {
    NSDictionary *parameters = @{@"channel": channel, @"count": @(6)};
    
    [[NNHttpClient sharedClient] getAtPath:kPathSlideShow
                                parameters:parameters
                             responseClass:[MainSlideShowModel class]
                                   success:^(id<Jsonable> response) {
                                       self.slideShowModel = response;
                                       if (success) {
                                           success();
                                       }
                                   }
                                   failure:^(ResponseError *error) {
                                       self.responseError = error;
                                       if (failure) {
                                           failure();
                                       }
                                   }];
}

- (void)requestForList:(NSString *)channel success:(void (^)())success failure:(void (^)())failure {
    NSDictionary *parameters = @{@"channel": channel, @"sort_type": @"new", @"count": @(36),
                                 @"offset": @(0)};
    
    [[NNHttpClient sharedClient] getAtPath:kPathWorkList
                                parameters:parameters
                             responseClass:[CommonListModel class]
                                   success:^(id<Jsonable> response) {
                                       self.listDataModel = response;
                                       if (success) {
                                           success();
                                       }
                                   }
                                   failure:^(ResponseError *error) {
                                       self.responseError = error;
                                       if (failure) {
                                           failure();
                                       }
                                   }];
}

- (void)requestData {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    void (^done)() = ^ {
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            [self.swipeView reloadItemAtIndex:self.currentPageIndex];
            self.swipeView.scrollEnabled = YES;
        });
    };
    
    void (^success)() = ^{
        if (self.listDataModel && self.slideShowModel) {
            [UserDefaults setInteger:[[NSDate date] timeIntervalSince1970] forKey:kLastUpdateKey];
            [UserDefaults synchronize];
            
            if (self.visible) {
                done();
            }
        }
    };
    
    void (^failure)() = ^{
        if (self.responseError && (!self.listDataModel || !self.slideShowModel)) {
            self.listDataModel = nil;
            self.slideShowModel = nil;
            
            if (self.visible) {
                [UIHelper alertWithMessage:self.responseError.message];
                
                done();
            }
            
            self.responseError = nil;
        }
    };

    [self requestForSlideShow:@"home"
                      success:^{
                          success();
                      }
                      failure:^{
                          failure();
                      }];
    
    [self requestForList:@"home"
                 success:^{
                     success();
                 }
                 failure:^{
                     failure();
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
    bottomLineLayer.name = kHeaderBottomLineName;
    bottomLineLayer.frame = CGRectMake(0, 26, 50, 2);
    bottomLineLayer.backgroundColor = HEXCOLOR(0x0096ff).CGColor;
    [label.layer addSublayer:bottomLineLayer];
    
    [headerView addSubview:label];
    
    return headerView;
}

- (UIView *)createFooterView {
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, CompatibleScreenWidth, 5)];
}

- (void)fillDataInHeaderView:(UIView *)headerView {
    MSSItem *model = !self.slideShowModel ? nil : self.slideShowModel.list[headerView.tag];
    
    __weak UIImageView *weakImageView = (UIImageView *)[headerView viewWithTag:kTagHeaderImageView];
    [weakImageView setImageWithURL:[NSURL URLWithString:model.imgUrl]
              placeholderImage:nil
                       success:^(UIImage *image, BOOL cached) {
                           weakImageView.highlightedImage = [image opacity:0.8];
                       }
                       failure:^(NSError *error) {
                           
                       }];
    
    TTTAttributedLabel *label = (TTTAttributedLabel *)[headerView viewWithTag:kTagHeaderLabel];
    label.text = model.title;
}

@end
