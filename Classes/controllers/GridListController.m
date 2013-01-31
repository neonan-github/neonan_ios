//
//  GridListController.m
//  Neonan
//
//  Created by capricorn on 13-1-31.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "GridListController.h"

#import "GridCell.h"

#import <KKGridView.h>

#import "SVPullToRefresh.h"

@interface GridListController () <KKGridViewDataSource, KKGridViewDelegate>

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
    navController.logoHidden = YES;
    self.title = @"TOP 99 女人";
    
    KKGridView *gridView = self.gridView = [[KKGridView alloc] initWithFrame:CGRectMake(0, 0, CompatibleScreenWidth, CompatibleContainerHeight)];
    gridView.backgroundColor = [UIColor clearColor];
    gridView.cellSize = CGSizeMake(100.f, 100.f);
    gridView.cellPadding = CGSizeMake(5.f, 5.f);
    gridView.dataSource = self;
    gridView.delegate = self;
    [self.view addSubview:gridView];
    [gridView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - KKGridViewDataSource methods

- (NSUInteger)gridView:(KKGridView *)gridView numberOfItemsInSection:(NSUInteger)section {
    return 20;
}

- (KKGridViewCell *)gridView:(KKGridView *)gridView cellForItemAtIndexPath:(KKIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    GridCell *cell = (GridCell *)[gridView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[GridCell alloc] initWithFrame:CGRectMake(0, 0, 100, 100) reuseIdentifier:cellIdentifier];
    }
    
    cell.imageView.image = [UIImage imageNamed:@"img_pic_sample.png"];
    
    return cell;
}

@end
