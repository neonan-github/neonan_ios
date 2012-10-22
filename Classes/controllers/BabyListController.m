//
//  BabyListController.m
//  Neonan
//
//  Created by capricorn on 12-10-22.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "BabyListController.h"
#import "SMPageControl.h"
#import "BabyCell.h"
#import <SVPullToRefresh.h>

@interface BabyListController ()
@property (nonatomic, unsafe_unretained) SlideShowView *slideShowView;
@property (nonatomic, unsafe_unretained) SMPageControl *pageControl;
@property (nonatomic, unsafe_unretained) UITableView *tableView;

@property (nonatomic, strong) NSArray *slideImages;
@end

@implementation BabyListController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    float layoutY = 0;
    
    SlideShowView *slideShowView = self.slideShowView = [[SlideShowView alloc] initWithFrame:CGRectMake(0, layoutY, 320, 100)];
    slideShowView.dataSource = self;
    slideShowView.delegate = self;
    [self.view addSubview:slideShowView];
    
    SMPageControl *pageControl = self.pageControl = [[SMPageControl alloc] initWithFrame:CGRectMake(0, layoutY + 100 - 20, 310, 20)];
    pageControl.alignment = SMPageControlAlignmentRight;
    pageControl.userInteractionEnabled = NO;
    [self.view addSubview:pageControl];
    
    layoutY += 100;
    UITableView *tableView = self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, layoutY, 320, 480 - layoutY) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView addPullToRefreshWithActionHandler:^{
        // refresh data
        // call [tableView.pullToRefreshView stopAnimating] when done
    }];
    [tableView addInfiniteScrollingWithActionHandler:^{
        // add data to data source, insert new cells into table view
    }];
    [self.view addSubview:tableView];
    
    self.slideImages = [[NSArray alloc] initWithObjects:@"home.jpg", @"baby.jpg", @"baby_detail.jpg", @"splash.jpg", @"article_detail.jpg", @"article_list.jpg", nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cleanUp
{
    self.slideShowView.delegate = nil;
    self.slideShowView.dataSource = nil;
    
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
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
    NSUInteger count = self.slideImages.count;
    [self.pageControl setNumberOfPages:count];
    return count;
    
}

- (UIView *)slideShowView:(SlideShowView *)slideShowView viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    if (!view) {
        view = [[[UIImageView alloc] init] autorelease];
        view.clipsToBounds = YES;
        view.contentMode = UIViewContentModeTop;
    }
    
    ((UIImageView *)view).image = [UIImage imageNamed:[self.slideImages objectAtIndex:index]];
    
    return view;
}

#pragma mark - SlideShowViewDelegate methods

- (void)slideShowViewItemIndexDidChange:(SlideShowView *)slideShowView {
    [self.pageControl setCurrentPage:slideShowView.carousel.currentItemIndex];
}

#pragma mark － UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.slideImages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    BabyCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[BabyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.thumbnail.image = [UIImage imageNamed:[self.slideImages objectAtIndex:indexPath.row]];
    cell.titleLabel.font = [UIFont systemFontOfSize:12];
    cell.titleLabel.text = [NSString stringWithFormat:@"title %u", indexPath.row];
    cell.descriptionLabel.font = [UIFont systemFontOfSize:12];
    cell.descriptionLabel.text = [NSString stringWithFormat:@"description %u", indexPath.row];
    cell.dateLabel.font = [UIFont systemFontOfSize:12];
    cell.dateLabel.text = [NSString stringWithFormat:@"date %u", indexPath.row];
    cell.videoShots = self.slideImages;
    return cell;
    
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

@end
