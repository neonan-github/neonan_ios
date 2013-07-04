//
//  SplashViewController.m
//  Neonan
//
//  Created by capricorn on 13-3-11.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "SplashViewController.h"

#import "PurchaseManager.h"

#import <UIImageView+WebCache.h>
#import <SDImageCache.h>

@interface SplashViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end

@implementation SplashViewController

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
    
    NSString *imageName = IS_IPHONE_5 ? @"Default-568h@2x.png" : (IS_RETINA ? @"Default@2x.png" : @"Default.png");
    _imageView.image = [UIImage imageFromFile:imageName];
    
    [_activityIndicatorView startAnimating];
}

- (void)cleanUp {
    self.imageView = nil;
    self.activityIndicatorView = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self validateContentLock];
    [self requestMotto];
    [[PurchaseManager sharedManager] commitUnnotifiedInfo:nil];
}

- (void)requestMotto {
    void ((^done)(MottoModel *motto)) = ^(MottoModel *motto) {
        [self dismissViewControllerAnimated:NO completion:^{
            if (self.done) {
                self.done(motto);
            }
        }];
    };
    
    [[NNHttpClient sharedClient] getAtPath:kPathMotto
                                parameters:nil
                             responseClass:[MottoModel class]
                                   success:^(id<Jsonable> response) {
                                       MottoModel *motto = response;
                                       NSURL *imgUrl = [NSURL URLWithString:motto.imageUrl];
                                       
                                       UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromKey:[imgUrl absoluteString]];
                                       if (cachedImage) {
                                           done(motto);
                                       } else {
                                           [[SDWebImageManager sharedManager] downloadWithURL:imgUrl
                                                                                     delegate:self
                                                                                      options:0
                                                                                      success:^(UIImage *image, BOOL cached) {
                                                                                          done(motto);
                                                                                      }
                                                                                      failure:^(NSError *error) {
                                                                                          done(nil);
                                                                                      }];
                                       }
                                       
                                   }
                                   failure:^(ResponseError *error) {
                                       done(nil);
                                   }];
}

- (void)validateContentLock {
#warning OnlyForTest
    [(NeonanAppDelegate *)ApplicationDelegate setContentLocked:YES];
}

@end
