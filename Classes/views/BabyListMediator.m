//
//  BabyListMediator.m
//  Neonan
//
//  Created by capricorn on 12-10-15.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "BabyListMediator.h"
#import "SlideShowView.h"
#import "StyledPageControl.h"
#import "BabyCell.h"
#import <SVPullToRefresh.h>

@interface BabyListMediator ()
@property (nonatomic, retain) SlideShowView *pagingView;
@property (nonatomic, retain) StyledPageControl *pageControl;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSArray *slideImages;
@end

@implementation BabyListMediator

- (void)viewDidLoad
{
    float layoutY = 0;
    
    UILabel *navBar = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)] autorelease];
    navBar.text = @"自定义导航栏";
    navBar.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
    navBar.textAlignment = NSTextAlignmentCenter;
    navBar.userInteractionEnabled = YES;
    [self addSubview:navBar];
    
    UIButton *back = [[[UIButton alloc] initWithFrame:CGRectMake(10, 5, 60, 30)] autorelease];
    back.layer.cornerRadius = 10;
    [back setBackgroundColor:[UIColor grayColor]];
    [back setTitle:@"返回" forState:UIControlStateNormal];
    [back setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [back setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:back];
    
    layoutY += 40;
    SlideShowView *pagingView = self.pagingView = [[[SlideShowView alloc] initWithFrame:CGRectMake(0, layoutY, 320, 100)] autorelease];
    pagingView.delegate = self;
    pagingView.gapBetweenPages = 0;
    [self addSubview:pagingView];
    
    StyledPageControl *pageControl = self.pageControl = [[[StyledPageControl alloc] initWithFrame:CGRectMake(220, layoutY + 100 - 20, 100, 20)] autorelease];
    [pageControl setPageControlStyle:PageControlStyleDefault];
    [self addSubview:pageControl];
    
    layoutY += 100;
    UITableView *tableView = self.tableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, layoutY, 320, 480 - layoutY) style:UITableViewStylePlain] autorelease];
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView addPullToRefreshWithActionHandler:^{
        // refresh data
        // call [tableView.pullToRefreshView stopAnimating] when done
    }];
    [tableView addInfiniteScrollingWithActionHandler:^{
        // add data to data source, insert new cells into table view
    }];
    [self addSubview:tableView];
    
    self.slideImages = [[[NSArray alloc] initWithObjects:@"home.jpg", @"baby.jpg", @"baby_detail.jpg", @"splash.jpg", @"article_detail.jpg", @"article_list.jpg", nil] autorelease];
}

- (void)dealloc
{
    NSLog(@"==> @(Just for test): GalleryContainerMediator dealloc!!");
    self.pagingView = nil;
    self.pagingView.delegate = nil;
    
    self.pageControl = nil;
    self.tableView = nil;
    
    [super dealloc];
}

- (void)back
{
    [self popMediatorWithAnimation:From_Left];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"==> @(Just for test): GalleryContainerMediator Appear!!");
    [self.pagingView reloadData];
    [self.pagingView startAutoScroll:2];
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"==> @(Just for test): GalleryContainerMediator Disappear!!");
    [self.pagingView stopAutoScroll];
}

#pragma mark － ATPagingViewDelegate methods

- (NSInteger)numberOfPagesInPagingView:(ATPagingView *)pagingView {
    NSUInteger count = self.slideImages.count;
    [self.pageControl setNumberOfPages:count];
    return count;
}

- (UIView *)viewForPageInPagingView:(ATPagingView *)pagingView atIndex:(NSInteger)index {
    UIImageView *view = (UIImageView *)[pagingView dequeueReusablePage];
    if (view == nil) {
        view = [[[UIImageView alloc] init] autorelease];
        view.clipsToBounds = YES;
        view.contentMode = UIViewContentModeTop;
    }
    
    view.image = [UIImage imageNamed:[self.slideImages objectAtIndex:index]];
    
    return view;
}

- (void)currentPageDidChangeInPagingView:(ATPagingView *)pagingView {
    [self.pageControl setCurrentPage:pagingView.currentPageIndex];
}

#pragma mark － UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.slideImages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    BabyCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[BabyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
    
    cell.thumbnail.image = [UIImage imageNamed:[self.slideImages objectAtIndex:indexPath.row]];
    cell.titleLabel.font = [UIFont systemFontOfSize:12];
    cell.titleLabel.text = [NSString stringWithFormat:@"title %u", indexPath.row];
    cell.descriptionLabel.font = [UIFont systemFontOfSize:12];
    cell.descriptionLabel.text = [NSString stringWithFormat:@"description %u", indexPath.row];
    cell.dateLabel.font = [UIFont systemFontOfSize:12];
    cell.dateLabel.text = [NSString stringWithFormat:@"date %u", indexPath.row];
    cell.playButton.backgroundColor = [UIColor greenColor];
    [cell.playButton setImage:[UIImage imageNamed:[self.slideImages objectAtIndex:indexPath.row]] forState:UIControlStateNormal];
    
    return cell;
    
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

@end
