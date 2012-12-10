//
//  ArticleDetailController.m
//  Neonan
//
//  Created by capricorn on 12-10-23.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "ArticleDetailController.h"
#import "SignController.h"
#import "CommentListController.h"
#import "NNNavigationController.h"
#import "ShareHelper.h"

#import "CommentBox.h"
#import <UIWebView+RemoveShadow.h>
#import <MBProgressHUD.h>

#import "NearWorksModel.h"
#import "ArticleDetailModel.h"

static NSString *kHtmlTemplate = @"<html> \n"
"<head> \n"
"<style type=\"text/css\"> \n"
"body {font-family: \"%@\"; font-size: %@em; color: white; padding: 1em;}\n"
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

@interface ArticleDetailController () <UIWebViewDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *titleLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *extraInfoLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *titleLineView;
@property (unsafe_unretained, nonatomic) IBOutlet UIWebView *textView;
@property (unsafe_unretained, nonatomic) IBOutlet CommentBox *commentBox;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *shareButton;
//@property (strong, nonatomic) IBOutlet UIButton *commentButton;
@property (strong, nonatomic) ShareHelper *shareHelper;

@property (strong, nonatomic) ArticleDetailModel *dataModel;
@property (strong, nonatomic) NearWorksModel *idModel;
@property (assign, nonatomic) NSInteger idIndex;

@property (unsafe_unretained, nonatomic) CALayer *cacheLayer;
@property (assign, nonatomic) BOOL isAnimating;

- (void)updateData;

- (void)adjustLayout:(NSString *)title;
@end

@implementation ArticleDetailController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = DarkThemeColor;
    UISwipeGestureRecognizer *swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    [swipeLeftRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipeLeftRecognizer];
    UISwipeGestureRecognizer *swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    [swipeRightRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeRightRecognizer];
    
    CustomNavigationBar *customNavigationBar = (CustomNavigationBar *)self.navigationController.navigationBar;
    // Create a custom back button
    UIButton* backButton = [UIHelper createBackButton:customNavigationBar];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    [self adjustLayout:_contentTitle];
    _titleLabel.text = _contentTitle;
    
    [_textView removeShadow];
    _textView.scalesPageToFit = YES;
    _textView.delegate = self;
    _textView.dataDetectorTypes = UIDataDetectorTypeNone;
    
//    [_commentButton removeFromSuperview];
//    [_commentButton addTarget:self action:@selector(showComments) forControlEvents:UIControlEventTouchUpInside];
//    _commentBox.rightView = _commentButton;
    [_commentBox.countButton addTarget:self action:@selector(showComments) forControlEvents:UIControlEventTouchUpInside];
    [_commentBox.doneButton addTarget:self action:@selector(publish:) forControlEvents:UIControlEventTouchUpInside];
    
    [_shareButton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.dataModel = nil;
}

- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [self setExtraInfoLabel:nil];
    [self setTextView:nil];
    [self setCommentBox:nil];
    [self setShareButton:nil];
    [self setTitleLineView:nil];
    
    self.shareHelper = nil;
    self.cacheLayer = nil;
    
    self.idModel = nil;
    
    [super viewDidUnload];
}

#pragma mark - UIViewController life cycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    if (!_idModel) {
        [self initIdList];
    } else if (!_dataModel) {
        [self requestForContent:_contentId showHUD:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
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
//   [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName(\"a\").removeAttribute(\"href\");"];
}

#pragma mark - Keyboard events handle

//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
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

-(void) keyboardWillHide:(NSNotification *)note{
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

- (void)requestForNearWorks:(BOOL)next success:(void (^)())success {
    static NSUInteger count = 3;
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:@"article", @"content_type",
                                _contentId, @"content_id",
                                _sortType == SortTypeHotest ? @"hot" : @"new", @"sort_type",
                                _channel, @"channel",
                                [NSNumber numberWithUnsignedInteger:_offset], @"offset",
                                [NSNumber numberWithUnsignedInteger:count], @"count",
                                next ? @"1" : @"-1", @"direction", @"true", @"filter", nil];
    
    [[NNHttpClient sharedClient] getAtPath:@"near_work_ids" parameters:parameters responseClass:[NearWorksModel class] success:^(id<Jsonable> response) {
        @synchronized(_idModel) {
            if (!next) {
                self.idIndex = _idIndex + [[((NearWorksModel *)response) items] count];
            }
            [_idModel insertMoreData:response withMode:next];
        }
        
        if (success) {
            success();
        }
    } failure:^(ResponseError *error) {
        NSLog(@"error:%@", error.message);
        [UIHelper alertWithMessage:error.message];
    }];
}

- (void)requestForContent:(NSString *)contentId showHUD:(BOOL)showHUD {
    if (showHUD) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:@"article", @"content_type",
                                contentId, @"content_id", [NSNumber numberWithUnsignedInteger:_offset], @"offset",
                                nil];
    
    [[NNHttpClient sharedClient] getAtPath:@"work_info" parameters:parameters responseClass:[ArticleDetailModel class] success:^(id<Jsonable> response) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
            
        self.dataModel = response;
        _dataModel.contentId = _contentId;
        [self updateData];
    } failure:^(ResponseError *error) {
        NSLog(@"error:%@", error.message);
        [UIHelper alertWithMessage:error.message];
    }];
}

- (void)publishComment:(NSString *)comment withContentId:(NSString *)contentId {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    SessionManager *sessionManager = [SessionManager sharedManager];
    [sessionManager requsetToken:self success:^(NSString *token) {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:token, @"token",
                                    contentId, @"content_id", comment, @"content", nil];
        
        [[NNHttpClient sharedClient] postAtPath:@"comments_create" parameters:parameters responseClass:nil success:^(id<Jsonable> response) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            _dataModel.commentNum++;
            [_commentBox.countButton setTitle:[NSNumber numberWithInteger:_dataModel.commentNum].description forState:UIControlStateNormal];
            _commentBox.countButton.enabled = _dataModel.commentNum > 0;
            _commentBox.text = @"";
        } failure:^(ResponseError *error) {
            NSLog(@"error:%@", error.message);
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [UIHelper alertWithMessage:error.message];
        }];

    }];
}

#pragma mark - Private UI related

- (void)adjustLayout:(NSString *)title {
    CGFloat titleOriginalHeight = _titleLabel.frame.size.height;
    CGFloat titleAdjustedHeight = [UIHelper computeHeightForLabel:_titleLabel withText:title];
    CGFloat delta = titleAdjustedHeight - titleOriginalHeight;
    
    CGRect frame = _titleLabel.frame;
    frame.size.height = titleAdjustedHeight;
    _titleLabel.frame = frame;
    
    frame = _extraInfoLabel.frame;
    frame.origin.y += delta;
    _extraInfoLabel.frame = frame;
    
    frame = _titleLineView.frame;
    frame.origin.y += delta;
    _titleLineView.frame = frame;
    
    frame = _textView.frame;
    frame.origin.y += delta;
    frame.size.height -= delta;
    _textView.frame = frame;
}

- (void)renderHtml:(NSString *)html {
    // Load HTML data
    //	NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"article_sample.html" ofType:nil];
    //	NSString *html = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:NULL];
    
    NSString *formattedHTML = [NSString stringWithFormat:kHtmlTemplate, @"helvetica", [NSNumber numberWithInt:2], html];
    //filter video,href,style
    formattedHTML = [formattedHTML stringByReplacingOccurrencesOfString:@"href=\"[^\"]+\"|<object.+<embed.+?>|style=\"[^\"]+\"" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, formattedHTML.length)];
    //adjust image width
    formattedHTML = [formattedHTML stringByReplacingOccurrencesOfString:@"<img" withString:@"<img style=\"width:100%;\"" options:NSRegularExpressionSearch range:NSMakeRange(0, formattedHTML.length)];
    [_textView loadHTMLString:formattedHTML baseURL:nil];
}

- (void)updateData {
    self.contentTitle = _dataModel.title;
    [self adjustLayout:_contentTitle];
    
    _titleLabel.text = _contentTitle;
    _titleLabel.hidden = NO;
    
    _extraInfoLabel.text = [NSString stringWithFormat:@"%@ 编辑：%@", _dataModel.date, _dataModel.author];
    _extraInfoLabel.hidden = NO;
    
    [_commentBox.countButton setTitle:[NSNumber numberWithInteger:_dataModel.commentNum].description forState:UIControlStateNormal];
    _commentBox.countButton.enabled = _dataModel.commentNum > 0;
    
    [self renderHtml:_dataModel.content];
    _textView.hidden = NO;
}

- (void)clearContents {
    self.dataModel = nil;
    
    _titleLabel.hidden = YES;
    _extraInfoLabel.hidden = YES;
    
    _commentBox.text = @"";
    [_commentBox.countButton setTitle:@"" forState:UIControlStateNormal];
    _commentBox.countButton.enabled = NO;
    
    [self renderHtml:@""];
    _textView.hidden = YES;
}

- (void)performBounce:(BOOL)left {
    CAAnimation *animation = [UIHelper createBounceAnimation:left ? NNDirectionLeft : NNDirectionRight];
    [CATransaction begin];
    [self.view.layer addAnimation:animation forKey:@"bounceAnimation"];
    [CATransaction commit];
}

#pragma mark - Private methods

- (void)initIdList {
    if (!_idModel) {
        self.idModel = [[NearWorksModel alloc] init];
        NearItem *item = [[NearItem alloc] init];
        item.contentId = _contentId;
        item.contentType = @"article";
        item.offset = _offset;
        _idModel.items = [NSMutableArray arrayWithObjects:item, nil];
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self requestForNearWorks:NO success:^{
            [self requestForNearWorks:YES success:^{
                NearItem *currentItem = [_idModel.items objectAtIndex:_idIndex];
                self.offset = [currentItem offset];
                self.contentId = [currentItem contentId];
                [self requestForContent:_contentId showHUD:NO];
            }];
        }];
    }
}

- (void)share {
    if (!_dataModel) {
        return;
    }
    
    if (!self.shareHelper) {
        self.shareHelper = [[ShareHelper alloc] initWithRootViewController:self];
    }
    
    _shareHelper.title = _dataModel.title;
    _shareHelper.shareUrl = _dataModel.shareUrl;
    [_shareHelper showShareView];
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
    CommentListController *controller = [[CommentListController alloc] init];
    controller.articleInfo = self.dataModel;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)swipe:(UISwipeGestureRecognizer *)recognizer {
    if (_isAnimating || !_dataModel) {
        return;
    }
    
    BOOL next = recognizer.direction == UISwipeGestureRecognizerDirectionLeft;
    
    NSInteger idIndex = _idIndex;
    idIndex += (next ? 1 : -1);
    if (idIndex < 0 || idIndex >= _idModel.items.count) {// 到头或尾
        [self performBounce:!next];
        return;
    }
    
    self.idIndex = idIndex;
    
    self.isAnimating = YES;
    
    CGFloat viewWidth = self.view.frame.size.width;
    CGFloat viewHeight = self.view.frame.size.height;
    
    CALayer *cacheLayer = self.cacheLayer = [CALayer layer];
    UIImage *cacheImage = [UIImage imageFromView:self.view];
    cacheLayer.frame = CGRectMake((next ? -1 : 1) * viewWidth, 0, viewWidth, viewHeight);
    cacheLayer.contents = (id)cacheImage.CGImage;
    [self.view.layer insertSublayer:cacheLayer above:self.view.layer];
    
    [self clearContents];
    
    NearItem *currentItem = [_idModel.items objectAtIndex:_idIndex];
    self.offset = [currentItem offset];
    NSString *contentId = self.contentId = [currentItem contentId];
    if ((idIndex == 0 && !next) || (idIndex == _idModel.items.count - 1 && next)) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self requestForNearWorks:next success:^{ // 获取上或下id
            [self requestForContent:contentId showHUD:NO];
        }];
    } else {
        [self requestForContent:contentId showHUD:YES];
    }
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
//    animation.duration = 5;
    animation.delegate = self;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.fromValue = [NSValue valueWithCGPoint:CGPointMake((next ? 1.5f : -0.5f) * viewWidth, viewHeight / 2)];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(viewWidth / 2, viewHeight / 2)];
    [self.view.layer addAnimation:animation forKey:@"position"];
}

#pragma mark - CAAnimationDelegate methods

- (void)animationDidStart:(CAAnimation *)anim {
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    self.isAnimating = !flag;
    [self.cacheLayer removeFromSuperlayer];
}

@end
