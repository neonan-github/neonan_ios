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
    self.textLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
    self.textLabel.text = [NSString stringWithFormat:@"%@\n\n ——%@", self.motto.content, self.motto.name];
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
    
    double delayInSeconds = 2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [[UIApplication sharedApplication] setStatusBarHidden:NO
                                                withAnimation:UIStatusBarAnimationFade];
        [self dismissModalViewControllerAnimated:NO];
    });
}

@end
