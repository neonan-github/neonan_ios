//
//  ArticleDetailController.m
//  Neonan
//
//  Created by capricorn on 12-10-23.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "ArticleDetailViewController.h"
#import "SignViewController.h"
#import "CommentListViewController.h"
#import "NNNavigationController.h"
#import "NearWorksModel.h"
#import "ArticleDetailModel.h"

#import "CommentBox.h"
#import "EncourageView.h"
#import "FunctionFlowView.h"

#import "EncourageHelper.h"
#import "ShareHelper.h"
#import "SessionManager.h"

#import "MarqueeLabel.h"

#import <UIWebView+RemoveShadow.h>
#import <MBProgressHUD.h>

static NSString *kHtmlTemplate = @"<html> \n"
"<head> \n"
"<style type=\"text/css\"> \n"
"body {font-family: \"%@\"; font-size: 2.7em; color: white; padding: 1em; line-height: 1.5em;}\n"
//"img {width: 300px;}\n"
"a:link {color: white; text-decoration: none;}\n"
"a:visited {color: white; text-decoration: none;}\n"
"a:hover {color: white; text-decoration: none;}\n"
"a:active {color: white; text-decoration: none;}\n"
"</style> \n"
"</head> \n"
"<body>%@</body> \n"
"</html>";

static NSString * const kDirectionLeft = @"-1";
static NSString * const kDirectionRight = @"1";

@interface ArticleDetailViewController () <UIWebViewDelegate>

@property (weak, nonatomic) MarqueeLabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIWebView *textView;
@property (weak, nonatomic) IBOutlet CommentBox *commentBox;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;

@property (nonatomic, readonly) FunctionFlowView *moreActionView;

@property (strong, nonatomic) ShareHelper *shareHelper;

@property (strong, nonatomic) ArticleDetailModel *dataModel;

@property (weak, nonatomic) CALayer *cacheLayer;
@property (assign, nonatomic) BOOL isAnimating;

@end

@implementation ArticleDetailViewController
@synthesize moreActionView = _moreActionView;

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
    
    MarqueeLabel *titleLabel = [UIHelper createNavMarqueeLabel];
    self.titleLabel = titleLabel;
    titleLabel.text = self.contentTitle;
    self.navigationItem.titleView = titleLabel;
    
    UIButton *backButton = [UIHelper createBackButton:self.navigationController.navigationBar];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    UIButton *navRightButton = [UIHelper createRightBarButton:@"icon_nav_flow.png"];
    self.actionButton = navRightButton;
    [navRightButton addTarget:self action:@selector(showMoreAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navRightButton];
    
    UISwipeGestureRecognizer *swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    [swipeLeftRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipeLeftRecognizer];
    UISwipeGestureRecognizer *swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    [swipeRightRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeRightRecognizer];
    
    [self.textView removeShadow];
    _textView.scalesPageToFit = YES;
    _textView.delegate = self;
    _textView.dataDetectorTypes = UIDataDetectorTypeNone;
    
//    [_commentButton removeFromSuperview];
//    [_commentButton addTarget:self action:@selector(showComments) forControlEvents:UIControlEventTouchUpInside];
//    _commentBox.rightView = _commentButton;
    [_commentBox.countButton addTarget:self action:@selector(showComments) forControlEvents:UIControlEventTouchUpInside];
    [_commentBox.doneButton addTarget:self action:@selector(publish:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.dataModel = nil;
}

- (void)cleanUp {
    _moreActionView = nil;
    
    self.titleLabel = nil;
    self.textView = nil;
    self.commentBox = nil;
    self.actionButton = nil;
    self.shareHelper = nil;
    self.cacheLayer = nil;
    
    self.dataModel = nil;
}

#pragma mark - UIViewController life cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    if (!_dataModel) {
        [self fetchDetailInfo:^(NSString *token) {
            [self requestForContent:_contentId token:token];
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
}

#pragma mark - UIWebViewDelegate methods

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    if(navigationType == UIWebViewNavigationTypeLinkClicked) {
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
}

#pragma mark - Keyboard events handle

//Code from Brett Schumann
- (void)keyboardWillShow:(NSNotification *)note {
//    _commentBox.rightView = nil;
    
    // get keyboard size and loctaion
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
	// get a rect for the textView frame
	CGRect containerFrame = self.commentBox.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    
//    CGRect tableFrame = self.tableView.frame;
//    tableFrame.size.height = containerFrame.origin.y - tableFrame.origin.y;
    
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
	
	// set views with new info
	self.commentBox.frame = containerFrame;
//    self.tableView.frame = tableFrame;
	
	// commit animations
	[UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)note {
//    _commentBox.rightView = _commentButton;
    
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
	
	// get a rect for the textView frame
	CGRect containerFrame = self.commentBox.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
//    CGRect tableFrame = self.tableView.frame;
//    tableFrame.size.height = containerFrame.origin.y - tableFrame.origin.y;
	
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
	// set views with new info
	self.commentBox.frame = containerFrame;
//    self.tableView.frame = tableFrame;
	
	// commit animations
	[UIView commitAnimations];
}

#pragma mark - Private Request methods

- (void)fetchDetailInfo:(void (^)(NSString *token))requestBlock {
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if ([[SessionManager sharedManager] canAutoLogin]) {
        [[SessionManager sharedManager] requsetToken:self success:^(NSString *token) {
            requestBlock(token);
        }];
        
        return;
    }
    
    requestBlock(nil);
}

- (void)requestNearDetailInfo:(BOOL)next contentId:(NSString *)contentId token:(NSString *)token success:(void (^)())success {
    NSMutableDictionary *parameters = [@{@"sort_type": _sortType == SortTypeHotest ? @"hot" : @"new",
                                       @"channel": _channel, @"content_type": @"article",
                                       @"content_id": _contentId, @"direction": @(next ? 1 : -1)} mutableCopy];
    if (token) {
        [parameters setObject:token forKey:@"token"];
    }
    
    [[NNHttpClient sharedClient] getAtPath:kPathNearWork
                                parameters:parameters
                             responseClass:[ArticleDetailModel class]
                                   success:^(id<Jsonable> response) {
                                       
                                       if (response) {
                                           if (success) {
                                               success();
                                           }
                                           
                                           [self onDetailFetched:response];
                                       } else {
                                           [self performBounce:!next];
                                       }
                                   }
                                   failure:^(ResponseError *error) {
                                       DLog(@"error:%@", error.message);
                                       if (self.isVisible) {
                                           [UIHelper alertWithMessage:error.message];
                                       }
                                   }];
}

- (void)requestForContent:(NSString *)contentId token:(NSString *)token {
    NSMutableDictionary *parameters = [[NSDictionary dictionaryWithObjectsAndKeys:@"article", @"content_type",
                                contentId, @"content_id", nil] mutableCopy];
    
    if (token) {
        [parameters setObject:token forKey:@"token"];
    }
    
    [[NNHttpClient sharedClient] getAtPath:kPathWorkInfo parameters:parameters responseClass:[ArticleDetailModel class] success:^(id<Jsonable> response) {
        [self onDetailFetched:response];
    } failure:^(ResponseError *error) {
        DLog(@"error:%@", error.message);
        if (self.isVisible) {
            [UIHelper alertWithMessage:error.message];
        }
    }];
}

- (void)requestFavorites:(NSString *)contentId up:(BOOL)up {
    SessionManager *sessionManager = [SessionManager sharedManager];
    [sessionManager requsetToken:self success:^(NSString *token) {
        NSDictionary *parameters = up ? @{@"token": token, @"content_id": contentId} : @{@"token": token, @"content_id": contentId, @"cancel": @"true"};
        
        [[NNHttpClient sharedClient] postAtPath:kPathDoFav parameters:parameters responseClass:nil success:^(id<Jsonable> response) {
            if ([contentId isEqualToString:[_contentId description]]) {
                _dataModel.favorited = up;
                self.moreActionView.favorited = up;
            }
            
        } failure:^(ResponseError *error) {
            DLog(@"error:%@", error.message);
        }];
    }];
}

- (void)publishComment:(NSString *)comment withContentId:(NSString *)contentId {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    SessionManager *sessionManager = [SessionManager sharedManager];
    [sessionManager requsetToken:self success:^(NSString *token) {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:token, @"token",
                                    contentId, @"content_id", comment, @"content", nil];
        
        [[NNHttpClient sharedClient] postAtPath:kPathPublishComment parameters:parameters responseClass:nil success:^(id<Jsonable> response) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            _dataModel.commentNum++;
            [_commentBox.countButton setTitle:[NSNumber numberWithInteger:_dataModel.commentNum].description forState:UIControlStateNormal];
            _commentBox.countButton.enabled = _dataModel.commentNum > 0;
            _commentBox.text = @"";
            
            [EncourageView displayScore:EncourageScoreComment at:CGPointMake(CompatibleScreenWidth / 2, 100)];
        } failure:^(ResponseError *error) {
            DLog(@"error:%@", error.message);
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            if (self.isVisible) {
                [UIHelper alertWithMessage:error.message];
            }
        }];

    }];
}

#pragma mark - Private UI related

- (void)renderHtml:(NSString *)html {
    // Load HTML data
    //	NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"article_sample.html" ofType:nil];
    //	NSString *html = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:NULL];
    
    NSString *formattedHTML = [NSString stringWithFormat:kHtmlTemplate, @"helvetica", html];
    //filter video,href,style
    formattedHTML = [formattedHTML stringByReplacingOccurrencesOfString:@"href=\"[^\"]+\"|<object.+<embed.+?>|style=\"[^\"]+\"" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, formattedHTML.length)];
    //adjust image width
    formattedHTML = [formattedHTML stringByReplacingOccurrencesOfString:@"<img" withString:@"<img style=\"width:100%;\"" options:NSRegularExpressionSearch range:NSMakeRange(0, formattedHTML.length)];
    [_textView loadHTMLString:formattedHTML baseURL:nil];
}

- (void)updateData {
    self.contentTitle = _dataModel.title;
    
    self.titleLabel.text = _contentTitle;
    self.titleLabel.hidden = NO;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.titleLabel performSelector:@selector(setTapToScroll:) withObject:@(YES) afterDelay:5];
    
    [self.moreActionView setFavorited:_dataModel.favorited];
    
    [_commentBox.countButton setTitle:[NSNumber numberWithInteger:_dataModel.commentNum].description forState:UIControlStateNormal];
    _commentBox.countButton.enabled = _dataModel.commentNum > 0;
    
    [self renderHtml:_dataModel.content];
    [self checkLoadedAfterDelay:0.5];
}

- (void)clearContents {
    self.dataModel = nil;
    
    self.titleLabel.hidden = YES;
    [self.titleLabel canPerformAction:@selector(setTapToScroll:) withSender:@(YES)];
    self.titleLabel.tapToScroll = NO;
    
    _commentBox.text = @"";
    [_commentBox.countButton setTitle:@"" forState:UIControlStateNormal];
    _commentBox.countButton.enabled = NO;
    
    [self.textView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    [self.textView reload];
    self.textView.layer.opacity = 0;
}

- (void)performBounce:(BOOL)left {
    CAAnimation *animation = [UIHelper createBounceAnimation:left ? NNDirectionLeft : NNDirectionRight];
    [CATransaction begin];
    [self.view.layer addAnimation:animation forKey:@"bounceAnimation"];
    [CATransaction commit];
}

#pragma mark - Private methods

- (FunctionFlowView *)moreActionView {
    if (!_moreActionView) {
        _moreActionView = [[FunctionFlowView alloc] initWithFrame:CGRectMake(CompatibleScreenWidth - 73, 5, 68, 53)];
        [_moreActionView.shareButton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
        [_moreActionView.favButton addTarget:self action:@selector(doFav) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _moreActionView;
}

- (IBAction)showMoreAction:(id)sender {
    [self.view addSubview:self.moreActionView];
}

- (NSString *)parseImageUrl:(NSString *)html {
    NSRange imgTagRange = [html rangeOfString:@"<img[^>]+src\\s*=\\s*['\"]([^'\"]+)['\"][^>]*>" options:NSRegularExpressionSearch];
    if (imgTagRange.location == NSNotFound) {
        return nil;
    }
    
    NSString *imageTag = [html substringWithRange:imgTagRange];
    DLog(@"image tag:%@", imageTag);
    
    NSString *src = [imageTag stringByReplacingOccurrencesOfString:@"<img[^>]+src\\s*=\\s*['\"]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, imageTag.length)];
    src = [src stringByReplacingOccurrencesOfString:@"['\"][^>]*>" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, src.length)];
    DLog(@"src:%@", src);
    
    return src;
}

- (void)share {
    if (!_dataModel) {
        return;
    }
    
    if (!self.shareHelper) {
        self.shareHelper = [[ShareHelper alloc] initWithRootViewController:self];
    }
    
    [self.shareHelper showShareView];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.shareHelper.shareText = _dataModel.title;
        self.shareHelper.shareUrl = _dataModel.shareUrl;
        self.shareHelper.shareImage = nil;
        self.shareHelper.shareImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[self parseImageUrl:_dataModel.content]]]];
    });
}

- (void)doFav {
    if (!_dataModel) {
        return;
    }
    
    BOOL up = !_dataModel.favorited;
    
    [self requestFavorites:[_contentId description] up:up];
}

- (void)publish:(UIButton *)button {
    NSString *comment = _commentBox.text;
    if (comment.length < 1) {
        [UIHelper alertWithMessage:@"评论不能为空"];
        return;
    }
    
    [self publishComment:_commentBox.text withContentId:_contentId];
}

- (void)showComments {
    CommentListViewController *controller = [[CommentListViewController alloc] init];
    controller.articleInfo = self.dataModel;
    
    [self.navigationController pushViewController:controller animated:NO];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.2f];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];
    [UIView commitAnimations];
}

- (void)onDetailFetched:(id<Jsonable>)response {
    self.dataModel = response;
    NSString *contentId = _dataModel.contentId;
    _contentId = _dataModel.contentId;
    
    Record *record = [[Record alloc] init];
    record.contentType = @"article";
    record.contentId = contentId;
    [[HistoryRecorder sharedRecorder] saveRecord:record];
    
    __weak ArticleDetailViewController *weakSelf = self;
    [EncourageHelper check:contentId contentType:@"article" afterDelay:5
                    should:^BOOL{
                        return [[contentId description] isEqualToString:[_contentId description]] &&
                        [[SessionManager sharedManager] canAutoLogin] && [weakSelf isVisible];
                    }
                   success:^(NSInteger point) {
                       [EncourageView displayScore:point at:CGPointMake(CompatibleScreenWidth / 2, 100)];
                   }];
    
    
    [self updateData];
}

- (void)swipe:(UISwipeGestureRecognizer *)recognizer {
    if (_isAnimating || !_dataModel || !self.channel || [self.channel isEqualToString:@"search"]) {
        return;
    }
    
    BOOL next = recognizer.direction == UISwipeGestureRecognizerDirectionLeft;
    
//    if ((_currentIndex >= _maxIndex && next) || (_currentIndex < 1 && !next)) {// 到头或尾
//        [self performBounce:!next];
//        return;
//    }
//
//    self.currentIndex += next ? 1 : -1;
    
    [self fetchDetailInfo:^(NSString *token) {
        [self requestNearDetailInfo:next contentId:_contentId token:token success:^{
            self.isAnimating = YES;
            
            CGFloat viewWidth = self.view.frame.size.width;
            CGFloat viewHeight = self.view.frame.size.height;
            
            CALayer *cacheLayer = self.cacheLayer = [CALayer layer];
            UIImage *cacheImage = [UIImage imageFromView:self.view];
            cacheLayer.frame = CGRectMake((next ? -1 : 1) * viewWidth, 0, viewWidth, viewHeight);
            cacheLayer.contents = (id)cacheImage.CGImage;
            [self.view.layer insertSublayer:cacheLayer above:self.view.layer];
            
            [self clearContents];
            
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
            //    animation.duration = 5;
            animation.delegate = self;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            animation.fromValue = [NSValue valueWithCGPoint:CGPointMake((next ? 1.5f : -0.5f) * viewWidth, viewHeight / 2)];
            animation.toValue = [NSValue valueWithCGPoint:CGPointMake(viewWidth / 2, viewHeight / 2)];
            [self.view.layer addAnimation:animation forKey:@"position"];
        }];
    }];
    
}

- (void)checkLoadedAfterDelay:(double)seconds {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (self.textView.loading) {
            [self checkLoadedAfterDelay:0.2];
        } else {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            self.textView.layer.opacity = 1;
        }
    });
}

#pragma mark - CAAnimationDelegate methods

- (void)animationDidStart:(CAAnimation *)anim {
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    self.isAnimating = !flag;
    [self.cacheLayer removeFromSuperlayer];
}

@end
