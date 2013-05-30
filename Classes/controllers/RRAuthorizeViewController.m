//
//  RRAuthorizeViewController.m
//  bang_ipad
//
//  Created by capricorn on 13-2-26.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "RRAuthorizeViewController.h"

@interface RRAuthorizeViewController () <UIWebViewDelegate>

@property (nonatomic, weak) UIActivityIndicatorView *indicatorView;
@property (nonatomic, weak) UIWebView *webView;

@end

@implementation RRAuthorizeViewController

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
//    self.title = @"授权";
    
    if (_showType == ShowTypePush) {
        UIButton* backButton = [UIHelper createBackButton:self.navigationController.navigationBar];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    } else {
        UIButton *cancelButton = [UIHelper createLeftBarButton:@"icon_nav_close.png"];
        [cancelButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    }
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, CompatibleScreenWidth, CompatibleContainerHeight)];
    self.webView = webView;
    webView.delegate = self;
    [self.view addSubview:webView];
    
    UIActivityIndicatorView * indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicatorView = indicatorView;
    [indicatorView setCenter:CGPointMake(CompatibleScreenWidth / 2, CompatibleContainerHeight / 2)];
    [self.view addSubview:indicatorView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSMutableDictionary *params = [_params mutableCopy];
    [params setObject:kWidgetDialogUA forKey:@"ua"];
    
    NSURL *url = [ROUtility generateURL:kAuthBaseURL params:params];
	NSLog(@"start load URL: %@", url);
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [_webView loadRequest:request];
    
    [_indicatorView startAnimating];
}

- (void)close {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UIWebView Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [_indicatorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
    [_indicatorView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [_indicatorView stopAnimating];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = request.URL;
    NSString *query = [url fragment]; // url中＃字符后面的部分。
    if (!query) {
        query = [url query];
    }
    NSDictionary *params = [ROUtility parseURLParams:query];
    NSString *accessToken = [params objectForKey:@"access_token"];
    //    NSString *error_desc = [params objectForKey:@"error_description"];
    NSString *errorReason = [params objectForKey:@"error"];
    if(nil != errorReason) {
        [self dialogDidCancel:nil];
        return NO;
    }
    if (navigationType == UIWebViewNavigationTypeLinkClicked)/*点击链接*/{
        BOOL userDidCancel = ((errorReason && [errorReason isEqualToString:@"login_denied"])||[errorReason isEqualToString:@"access_denied"]);
        if(userDidCancel){
            [self dialogDidCancel:url];
        }else {
            NSString *q = [url absoluteString];
            if (![q hasPrefix:kAuthBaseURL]) {
                [[UIApplication sharedApplication] openURL:request.URL];
            }
        }
        return NO;
    }
    if (navigationType == UIWebViewNavigationTypeFormSubmitted) {//提交表单
        NSString *state = [params objectForKey:@"flag"];
        if ((state && [state isEqualToString:@"success"])||accessToken) {
            [self dialogDidSucceed:url];
        }
    }
    return YES;
}

- (void)dialogDidSucceed:(NSURL *)url {
	NSString *q = [url absoluteString];
    NSString *token = [ROUtility getValueStringFromUrl:q forParam:@"access_token"];
    NSString *expTime = [ROUtility getValueStringFromUrl:q forParam:@"expires_in"];
    NSDate   *expirationDate = [ROUtility getDateFromString:expTime];
    NSDictionary *responseDic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:token,expirationDate,nil]
                                                            forKeys:[NSArray arrayWithObjects:@"token",@"expirationDate",nil]];
    self.response = [ROResponse responseWithRootObject:responseDic];
    
    if ((token == (NSString *) [NSNull null]) || (token.length == 0)) {
        [self dialogDidCancel:nil];
    } else {
        if ([_renrenEngine respondsToSelector:@selector(authDialog:withOperateType:)])  {
            [_renrenEngine authDialog:self withOperateType:RODialogOperateSuccess];
        }
    }
}

- (void)dialogDidCancel:(NSURL *)url {
    if ([_renrenEngine respondsToSelector:@selector(authDialog:withOperateType:)]){
        [_renrenEngine authDialog:self withOperateType:RODialogOperateCancel];
    }
}

@end
