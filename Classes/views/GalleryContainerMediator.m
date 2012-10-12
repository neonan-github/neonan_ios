//
//  GalleryContainerMediator.m
//  Neonan
//
//  Created by capricorn on 12-10-11.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "GalleryContainerMediator.h"
#import "StyledPageControl.h"
#import "HotListCell.h"

@interface GalleryContainerMediator ()
@property (nonatomic, retain) SlideShowView *pagingView;
@property (nonatomic, retain) StyledPageControl *pageControl;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSArray *images;
@end

@implementation GalleryContainerMediator
@synthesize pagingView = _pagingView, pageControl = _pageControl, tableView = _tableView;
@synthesize images = _images;

- (void)viewDidLoad
{
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
    
    SlideShowView *pagingView = self.pagingView = [[[SlideShowView alloc] initWithFrame:CGRectMake(0, 40, 320, 100)] autorelease];
    pagingView.delegate = self;
    pagingView.gapBetweenPages = 0;
    [self addSubview:pagingView];
    
    StyledPageControl *pageControl = self.pageControl = [[[StyledPageControl alloc] initWithFrame:CGRectMake(220, 120, 100, 20)] autorelease];
    [pageControl setPageControlStyle:PageControlStyleDefault]; 
    [self addSubview:pageControl];
    
    UITableView *tableView = self.tableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 140, 320, 340) style:UITableViewStylePlain] autorelease];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self addSubview:tableView];
    
    self.images = [[[NSArray alloc] initWithObjects:@"home.jpg", @"baby.jpg", @"baby_detail.jpg", @"splash.jpg", nil] autorelease];
}

- (void)dealloc
{
    NSLog(@"==> @(Just for test): GalleryContainerMediator dealloc!!");
    self.pagingView = nil;
    self.pagingView.delegate = nil;
    
    self.pageControl = nil;
    
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
    NSUInteger count = self.images.count;
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
    
    view.image = [UIImage imageNamed:[self.images objectAtIndex:index]];
    
    return view;
}

- (void)currentPageDidChangeInPagingView:(ATPagingView *)pagingView {
    [self.pageControl setCurrentPage:pagingView.currentPageIndex];
}

#pragma mark － UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.images.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    HotListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[HotListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
    
    cell.thumbnail.image = [UIImage imageNamed:[self.images objectAtIndex:indexPath.row]];
    cell.titleLabel.font = [UIFont systemFontOfSize:12];
    cell.titleLabel.text = [NSString stringWithFormat:@"title %u", indexPath.row];
    cell.descriptionLabel.font = [UIFont systemFontOfSize:12];
    cell.descriptionLabel.text = [NSString stringWithFormat:@"description %u", indexPath.row];
    cell.dateLabel.font = [UIFont systemFontOfSize:12];
    cell.dateLabel.text = [NSString stringWithFormat:@"date %u", indexPath.row];
    
    return cell;

}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

@end
