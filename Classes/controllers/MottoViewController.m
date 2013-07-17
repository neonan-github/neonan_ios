//
//  MottoViewController.m
//  Neonan
//
//  Created by capricorn on 13-6-25.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "MottoViewController.h"

#import <TTTAttributedLabel.h>
#import <UIImageView+WebCache.h>

@interface MottoViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *textLabel;

@end

@implementation MottoViewController

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
    
    [self.imageView setImageWithURL:[NSURL URLWithString:self.motto.imageUrl]];
    
    self.textLabel.font = [UIFont fontWithName:@"STYuanti-SC-Regular" size:17];
    self.textLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentCenter;
    self.textLabel.text = [NSString stringWithFormat:@"%@\n\n ——%@", self.motto.content, self.motto.name];
    
    double delayInSeconds = 3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        UIViewController *fromViewController = self;
        UIViewController *toViewController = [(NeonanAppDelegate *)ApplicationDelegate containerController];
        [[UIApplication sharedApplication] setStatusBarHidden:NO
                                                withAnimation:UIStatusBarAnimationFade];
        [self dismissModalViewControllerAnimated:NO];
        
        [toViewController.view.window addSubview:fromViewController.view];
        fromViewController.view.alpha = 1;
        fromViewController.view.transform = CGAffineTransformMakeScale(1, 1);
        toViewController.view.alpha = 0;
        [UIView animateWithDuration:0.8
                         animations:^{
                             fromViewController.view.alpha = 0;
                             fromViewController.view.transform = CGAffineTransformMakeScale(1.3, 1.3);
                             toViewController.view.alpha = 1;
                         }
                         completion:^(BOOL finished) {
                             [fromViewController.view removeFromSuperview];
                         }];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cleanUp {
    [super cleanUp];
    
    self.imageView = nil;
    self.textLabel = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

@end
