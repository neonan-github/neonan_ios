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

#import "ArticleDetailModel.h"

static NSString *kHtmlTemplate = @"<html> \n"
"<head> \n"
"<style type=\"text/css\"> \n"
"body {font-family: \"%@\"; font-size: %@em; color: white; padding: 1em;}\n"
"a:link {color: white; text-decoration: none;}\n"
"a:visited {color: white; text-decoration: none;}\n"
"a:hover {color: white; text-decoration: none;}\n"
"a:active {color: white; text-decoration: none;}\n"
"</style> \n"
"</head> \n"
"<body>%@</body> \n"
"</html>";

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

- (void)requestForHtml:(NSString *)contentId;
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
    self.shareHelper = nil;
    [self setTitleLineView:nil];
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
    if (_dataModel) {
        [self updateData];
    } else {
        [self requestForHtml:_contentId];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
}

#pragma mark - UIWebViewDelegate methods

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"shouldStartLoadWithRequest type:%d", navigationType);
    if(navigationType == UIWebViewNavigationTypeLinkClicked) {
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
   [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName(\"a\").removeAttribute(\"href\");"]; 
//   [webView stringByEvaluatingJavaScriptFromString:@"document.anchors[\"ancDevx\"].removeAttribute(\"href\");"]; 
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

- (void)requestForHtml:(NSString *)contentId {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES]; 
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:@"article", @"content_type",
                                contentId, @"content_id", nil];
    
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
    //filter video
    formattedHTML = [formattedHTML stringByReplacingOccurrencesOfString:@"<object.+<embed.+?>" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, formattedHTML.length)];
    //adjust image width
    formattedHTML = [formattedHTML stringByReplacingOccurrencesOfString:@"style=\"[^\"]+\"" withString:@"style=\"width:100%;\"" options:NSRegularExpressionSearch range:NSMakeRange(0, formattedHTML.length)];
    [_textView loadHTMLString:formattedHTML baseURL:nil];
}

- (void)updateData {
    _titleLabel.text = _dataModel.title;
    _extraInfoLabel.text = [NSString stringWithFormat:@"%@ 编辑：%@", _dataModel.date, _dataModel.author];
    [_commentBox.countButton setTitle:[NSNumber numberWithInteger:_dataModel.commentNum].description forState:UIControlStateNormal];
    _commentBox.countButton.enabled = _dataModel.commentNum > 0;
    [self renderHtml:_dataModel.content];
}

#pragma mark - Private methods

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

@end
