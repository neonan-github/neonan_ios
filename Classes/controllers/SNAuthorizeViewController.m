//
//  SNAuthorizeViewController.m
//  HaHa
//
//  Created by capricorn on 12-12-17.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "SNAuthorizeViewController.h"
#import "SinaWeiboRequest.h"
#import "SinaWeibo.h"
#import "SinaWeiboConstants.h"
#import <QuartzCore/QuartzCore.h>

@interface SNAuthorizeViewController () <UIWebViewDelegate>

@property (nonatomic, weak) UIActivityIndicatorView *indicatorView;
@property (nonatomic, weak) UIWebView *webView;

@end

@implementation SNAuthorizeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//- (id)initWithAuthParams:(NSDictionary *)params
//                delegate:(id<SinaWeiboAuthorizeViewDelegate>)_delegate
//{
//    if ((self = [self init]))
//    {
//        self.delegate = _delegate;
//        authParams = [params copy];
//        appRedirectURI = [[authParams objectForKey:@"redirect_uri"] retain];
//    }
//    return self;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = @"授权";
    
    if (_showType == ShowTypePush) {
        CustomNavigationBar *customNavigationBar = (CustomNavigationBar *)self.navigationController.navigationBar;
        UIButton* backButton = [UIHelper createBackButton:customNavigationBar];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    } else {
        UIButton *cancelButton = [UIHelper createBarButton:10];
        cancelButton.frame = CGRectMake(14, 8, 42, 24);
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton addTarget:self.navigationController action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    }
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 460, 453)];
    self.webView = webView;
    webView.delegate = self;
    [self.view addSubview:webView];
    
    UIActivityIndicatorView * indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicatorView = indicatorView;
    [indicatorView setCenter:CGPointMake(460 / 2, 453 / 2)];
    [self.view addSubview:indicatorView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.view.superview.backgroundColor = [UIColor clearColor];
    self.navigationController.view.superview.layer.cornerRadius = 0;
    self.navigationController.view.superview.layer.borderColor = HEXCOLOR(0x3a82e5).CGColor;
    self.navigationController.view.superview.layer.borderWidth = 1;
    self.navigationController.view.superview.clipsToBounds = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSString *authPagePath = [SinaWeiboRequest serializeURL:kSinaWeiboWebAuthURL
                                                     params:_params httpMethod:@"GET"];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:authPagePath]]];
    [_indicatorView startAnimating];
}

//- (void)close {
//    [self dismissModalViewControllerAnimated:YES];
//}

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

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *url = request.URL.absoluteString;
    NSLog(@"url = %@", url);
    
    NSString *appRedirectURI = _params[@"redirect_uri"];
    NSString *siteRedirectURI = [NSString stringWithFormat:@"%@%@", kSinaWeiboSDKOAuth2APIDomain, appRedirectURI];
    
    if ([url hasPrefix:appRedirectURI] || [url hasPrefix:siteRedirectURI])
    {
        NSString *error_code = [SinaWeiboRequest getParamValueFromUrl:url paramName:@"error_code"];
        
        if (error_code)
        {
            NSString *error = [SinaWeiboRequest getParamValueFromUrl:url paramName:@"error"];
            NSString *error_uri = [SinaWeiboRequest getParamValueFromUrl:url paramName:@"error_uri"];
            NSString *error_description = [SinaWeiboRequest getParamValueFromUrl:url paramName:@"error_description"];
            
            NSDictionary *errorInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                       error, @"error",
                                       error_uri, @"error_uri",
                                       error_code, @"error_code",
                                       error_description, @"error_description", nil];
            
            [_webView stopLoading];
            [_weiboEngine authorizeView:nil didFailWithErrorInfo:errorInfo];
        }
        else
        {
            NSString *code = [SinaWeiboRequest getParamValueFromUrl:url paramName:@"code"];
            if (code)
            {
                [_webView stopLoading];
                [_weiboEngine authorizeView:nil didRecieveAuthorizationCode:code];
            }
        }
        
        return NO;
    }
    
    return YES;
}

@end
