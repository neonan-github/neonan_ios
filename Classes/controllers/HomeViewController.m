//
//  HomeViewController.m
//  Neonan
//
//  Created by capricorn on 13-5-23.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "HomeViewController.h"

#import "HomeGridViewCell.h"

#import <SwipeView.h>
#import <AQGridView.h>

static const NSInteger kPageCount = 6;

@interface HomeViewController () <SwipeViewDelegate, SwipeViewDataSource,
AQGridViewDelegate, AQGridViewDataSource>

@property (weak, nonatomic) IBOutlet SwipeView *swipeView;

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
    
    self.swipeView.dataSource = self;
    self.swipeView.delegate = self;
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
    AQGridView *gridView = (AQGridView *)view;
    
    if (!view) {   
        gridView = [[AQGridView alloc] initWithFrame:CGRectMake(0, 0, CompatibleScreenWidth, CompatibleContainerHeight)];
        gridView.contentSizeGrowsToFillBounds = NO;
        gridView.leftContentInset = 5;
//        gridView.rightContentInset = 10;
//        gridView.layoutDirection = AQGridViewLayoutDirectionHorizontal;
        gridView.backgroundColor = [UIColor redColor];
        gridView.dataSource = self;
        gridView.delegate = self;
        
        UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 167)];
        headerImageView.backgroundColor = [UIColor greenColor];
        gridView.gridHeaderView = headerImageView;
    }
    
    gridView.tag = index;
    [gridView reloadData];
    
    return gridView;
}

#pragma mark - AQGridViewDataSource methods

- (NSUInteger)numberOfItemsInGridView:(AQGridView *)gridView {
    return 6;
}

- (AQGridViewCell *)gridView:(AQGridView *)gridView cellForItemAtIndex:(NSUInteger)index {
    static NSString *CellIdentifier = @"Cell";
    
    HomeGridViewCell * cell = (HomeGridViewCell *)[gridView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[HomeGridViewCell alloc] initWithFrame:CGRectMake(0.0, 0.0, 145.0, 116.0) reuseIdentifier:CellIdentifier];
        cell.contentView.backgroundColor = [UIColor blueColor];
    }
    
    return cell;
}

- (CGSize)portraitGridCellSizeForGridView:(AQGridView *)gridView {
    return CGSizeMake(155.0, 126.0);
}

@end
