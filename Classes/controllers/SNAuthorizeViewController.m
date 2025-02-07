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
    
    NSString *authPagePath = [SinaWeiboRequest serializeURL:kSinaWeiboWebAuthURL
                                                     params:_params httpMethod:@"GET"];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:authPagePath]]];
    [_indicatorView startAnimating];
}

- (void)close {
    [self dismissViewControllerAnimated:YES completion:nil];
//    [self dismissModalViewControllerAnimated:YES];
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

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *url = request.URL.absoluteString;
    DLog(@"url = %@", url);
    
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
