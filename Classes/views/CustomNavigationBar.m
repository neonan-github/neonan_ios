//
//  CustomNavigationBar.m
//  Neonan
//
//  Created by capricorn on 12-10-25.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "CustomNavigationBar.h"

@interface CustomNavigationBar ()

@property (unsafe_unretained, nonatomic) UIButton *backButton;

@end

@implementation CustomNavigationBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //    navigationBar.topLineColor = [UIColor blackColor];
        //    navigationBar.bottomLineColor = [UIColor blackColor];
        //    navigationBar.gradientStartColor = [UIColor blackColor];
        //    navigationBar.gradientEndColor = [UIColor blackColor];
        UIImage *image = [UIHelper imageFromFile:@"icon_left_arrow_white.png"];
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, (44 - image.size.height) / 2, image.size.width, image.size.height)];
        [backButton setBackgroundImage:image forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:backButton];
        self.backItem.backBarButtonItem = nil;
        
        UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake((320 - 86) / 2, (44 - 26) / 2, 86, 26)];
        logoView.image = [UIImage imageNamed:@"img_logo.png"];
        [self addSubview:logoView];

    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
