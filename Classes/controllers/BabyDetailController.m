//
//  BabyDetailController.m
//  Neonan
//
//  Created by capricorn on 12-10-22.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "BabyDetailController.h"
#import "SMPageControl.h"
#import "NSString+TruncateToWidth.h"
#import "UnselectableTextView.h"

static const float kDescriptionShrinkedLines = 4;
static const float kDescriptionStretchedLines = 7;

@interface BabyDetailController ()
@property (nonatomic, unsafe_unretained) UILabel *navigationBar;
@property (nonatomic, unsafe_unretained) SlideShowView *slideShowView;
@property (nonatomic, unsafe_unretained) SMPageControl *pageControl;
@property (nonatomic, unsafe_unretained) UILabel *descriptionLabel;
@property (nonatomic, unsafe_unretained) UIScrollView *descriptionContainer;
@property (nonatomic, unsafe_unretained) UnselectableTextView *descriptionView;

@property (nonatomic, strong) NSArray *slideImages;
@property (nonatomic, strong) NSString *description;
@end

@implementation BabyDetailController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.description = @"杨棋涵毕业于中国音乐学院，有“小范冰冰”之称。以性感、冷艳、奢华、高贵等多种造型成为2010年娱乐媒体关注的焦点，更是频频亮相《男人装》、《瑞丽》、《时尚芭莎》等时尚杂志。";
    
    SlideShowView *slideShowView = self.slideShowView = [[SlideShowView alloc] initWithFrame:CGRectMake(0, -44, 320, 460)];
    slideShowView.dataSource = self;
    slideShowView.delegate = self;
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [slideShowView addGestureRecognizer:tapRecognizer];
    [self.view addSubview:slideShowView];
    
    UnselectableTextView *descriptionView = self.descriptionView = [[UnselectableTextView alloc] initWithFrame:CGRectMake(0, 356, 320, 0)];
    descriptionView.backgroundColor = [UIColor lightGrayColor];
    descriptionView.editable = NO;
    //    descriptionView.scrollEnabled = NO;
    descriptionView.text = [self.description stringByTruncatingToWidth:(self.descriptionView.contentSize.width - 16) * kDescriptionShrinkedLines withFont:descriptionView.font andEllipsis:@"…  "];
    //    [UIHelper fitScrollView:descriptionView withMaxHeight:kDescriptionStretchedLines * self.descriptionView.font.lineHeight];
    //    [UIHelper view:descriptionView alignBottomTo:460];
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [descriptionView addGestureRecognizer:tapRecognizer];
    [self.view addSubview:descriptionView];
    
    SMPageControl *pageControl = self.pageControl = [[SMPageControl alloc] initWithFrame:CGRectMake(0, 390, 320, 20)];
    pageControl.userInteractionEnabled = NO;
    [self.view addSubview:pageControl];
    
    self.slideImages = [[NSArray alloc] initWithObjects:@"home.jpg", @"baby.jpg", @"baby_detail.jpg", @"splash.jpg", @"article_detail.jpg", @"article_list.jpg", nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cleanUp
{
    self.slideShowView.dataSource = nil;
    self.slideShowView.delegate = nil;
    self.slideShowView = nil;
    
    self.pageControl = nil;
    
    self.descriptionLabel = nil;
    self.descriptionView = nil;
    self.descriptionContainer = nil;
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
    
    [self.slideShowView reloadData];
    [UIHelper fitScrollView:self.descriptionView withMaxHeight:kDescriptionStretchedLines * self.descriptionView.font.lineHeight];
    [UIHelper view:self.descriptionView alignBottomTo:356];
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

#pragma mark - Private methods

- (void)tap:(UITapGestureRecognizer *)recognizer {
    NSLog(@"touched view:%@", recognizer.view);
    
    if (recognizer.view == self.descriptionView) {
        BOOL shrinked = !self.descriptionView.scrollEnabled;
        self.descriptionView.text = self.descriptionView.scrollEnabled ? [self.description stringByTruncatingToWidth:(self.descriptionView.contentSize.width - 16) * kDescriptionShrinkedLines withFont:self.descriptionView.font andEllipsis:@"…  "] : self.description;
        [self.descriptionView scrollsToTop];
        self.descriptionView.scrollEnabled = shrinked;
        [UIHelper fitScrollView:self.descriptionView withMaxHeight:kDescriptionStretchedLines * self.descriptionView.font.lineHeight];
        [UIHelper view:self.descriptionView alignBottomTo:460];
    } else {
        BOOL hidden = self.navigationBar.frame.origin.y >= 0;
        float navigationBarDeltaY = -self.navigationBar.frame.size.height * (hidden ? 1 : 0);
        float descriptionViewDeltaY = self.descriptionView.frame.size.height * (hidden ? 1 : 0);
        [UIView animateWithDuration:0.3 delay:0
                            options:(hidden ? UIViewAnimationOptionCurveEaseIn : UIViewAnimationOptionCurveEaseOut)
                         animations:^{
                             self.navigationBar.transform = CGAffineTransformMakeTranslation(0, navigationBarDeltaY);
                             self.descriptionView.transform = CGAffineTransformMakeTranslation(0, descriptionViewDeltaY);
                         } completion:nil];
    }
}

@end
