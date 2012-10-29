//
//  BabyDetailController.m
//  Neonan
//
//  Created by capricorn on 12-10-22.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "BabyDetailController.h"
#import "NNNavigationController.h"
#import "SMPageControl.h"

static const float kDescriptionShrinkedLines = 4;
static const float kDescriptionStretchedLines = 7;

@interface BabyDetailController ()
@property (nonatomic, unsafe_unretained) UIView *titleBox;
@property (nonatomic, unsafe_unretained) UILabel *titleLabel;
@property (nonatomic, unsafe_unretained) UIButton *likeButton;
@property (nonatomic, unsafe_unretained) UIButton *shareButton;

@property (nonatomic, unsafe_unretained) SlideShowView *slideShowView;
@property (nonatomic, unsafe_unretained) SMPageControl *pageControl;
@property (nonatomic, unsafe_unretained) FoldableTextBox *textBox;

@property (nonatomic, strong) NSArray *slideImages;
@property (nonatomic, strong) NSString *description;
@end

@implementation BabyDetailController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.description = @"杨棋涵毕业于中国音乐学院，有“小范冰冰”之称。以性感、冷艳、奢华、高贵等多种造型成为2010年娱乐媒体关注的焦点，更是频频亮相《男人装》、《瑞丽》、《时尚芭莎》等时尚杂志。";
    
    SlideShowView *slideShowView = self.slideShowView = [[SlideShowView alloc] initWithFrame:CGRectMake(0, -NavBarHeight, CompatibleScreenWidth, CompatibleScreenHeight - StatusBarHeight)];
    slideShowView.dataSource = self;
    slideShowView.delegate = self;
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [slideShowView addGestureRecognizer:tapRecognizer];
    [self.view addSubview:slideShowView];
    
    UILabel *titleLabel = self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = @"杨棋涵";
    UIButton *likeButton = self.likeButton = [[UIButton alloc] initWithFrame:CGRectMake(238, 4, 26, 22)];
    [likeButton setBackgroundImage:[UIImage imageFromFile:@"icon_favorite_normal.png"] forState:UIControlStateNormal];
    [likeButton setBackgroundImage:[UIImage imageFromFile:@"icon_favorite_highlighted.png"] forState:UIControlStateHighlighted];
    UIButton *shareButton = self.shareButton = [[UIButton alloc] initWithFrame:CGRectMake(278, 4, 26, 22)];
    [shareButton setBackgroundImage:[UIImage imageFromFile:@"icon_share.png"] forState:UIControlStateNormal];
    UIView *titleBox = self.titleBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CompatibleScreenWidth, 30)];
    titleBox.backgroundColor = [UIColor blackColor];
    [titleBox addSubview:titleLabel];
    [titleBox addSubview:likeButton];
    [titleBox addSubview:shareButton];
    [self.view addSubview:titleBox];
    
    CGRect frame = CGRectMake(0, CompatibleContainerHeight - 32, CompatibleScreenWidth, 0);
    FoldableTextBox *textBox = self.textBox = [[FoldableTextBox alloc] initWithFrame:frame];
    frame.size.height = [textBox getSuggestedHeight];
    textBox.frame = frame;
    textBox.delegate = self;
    textBox.insets = UIEdgeInsetsMake(0, 10, 25, 20);
    [self.view addSubview:textBox];
    
    SMPageControl *pageControl = self.pageControl = [[SMPageControl alloc] initWithFrame:CGRectMake(0, CompatibleContainerHeight - 26, CompatibleScreenWidth, 20)];
    pageControl.userInteractionEnabled = NO;
    [self.view addSubview:pageControl];
    
    self.slideImages = [[NSArray alloc] initWithObjects:@"home.jpg", @"baby_list.jpg", @"baby_detail.jpg", @"splash.jpg", @"article_detail.jpg", @"article_list.jpg", nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cleanUp
{
    self.titleLabel = nil;
    self.likeButton = nil;
    self.shareButton = nil;
    self.titleBox = nil;
    
    self.slideShowView.dataSource = nil;
    self.slideShowView.delegate = nil;
    self.slideShowView = nil;
    
    self.pageControl = nil;
    
    self.textBox.delegate = nil;
    self.textBox = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self cleanUp];
}

- (void)dealloc
{
    [self cleanUp];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ((NNNavigationController *)self.navigationController).showsBackButton = YES;
    
    [self.slideShowView reloadData];
    self.textBox.expanded = NO;
}

#pragma mark - SlideShowViewDataSource methods

- (NSUInteger)numberOfItemsInSlideShowView:(SlideShowView *)slideShowView {
    NSUInteger count = self.slideImages.count;
    [self.pageControl setNumberOfPages:count];
    return count;
    
}

- (UIView *)slideShowView:(SlideShowView *)slideShowView viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    if (!view) {
        view = [[UIImageView alloc] init];
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

#pragma mark - FoldableTextBoxDelegate methods

- (void)onFrameChanged:(CGRect)frame {
    frame.origin.y = CompatibleContainerHeight - frame.size.height;
    self.textBox.frame = frame;
}

#pragma mark - Private methods

- (void)tap:(UITapGestureRecognizer *)recognizer {
    BOOL hidden = !self.navigationController.navigationBarHidden;
    
    [UIView beginAnimations:nil context:nil];
    [self.navigationController setNavigationBarHidden:hidden animated:YES];
    
    CGRect frame = self.slideShowView.frame;
    frame.origin.y = hidden ? 0 : -NavBarHeight;
    self.slideShowView.frame = frame;
    
    frame = self.titleBox.frame;
    frame.origin.y = hidden ? -30 : 0;
    self.titleBox.frame = frame;
    
    frame = self.textBox.frame;
    frame.origin.y = hidden ? (CompatibleScreenHeight - StatusBarHeight) : (CompatibleContainerHeight - frame.size.height);
    self.textBox.frame = frame;
//    方法一
//    frame = self.pageControl.frame;
//    frame.origin.y = hidden ? (390 + 44) : 390;
//    self.pageControl.frame = frame;
    //方法二
    self.pageControl.transform = CGAffineTransformMakeTranslation(0, hidden ? NavBarHeight : 0);
    [UIView commitAnimations];
}


@end
