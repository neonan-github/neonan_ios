//
//  UIHelper.m
//  Neonan
//
//  Created by capricorn on 12-10-18.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "UIHelper.h"

@implementation UIHelper
+ (void)fitScrollView:(UIScrollView *)scrollView withMaxHeight:(float)maxHeight {
    CGRect frame = scrollView.frame;
    frame.size.height = MIN(maxHeight, scrollView.contentSize.height);
    scrollView.frame = frame;
}

+ (void)view:(UIView *)view alignBottomTo:(float)bottom {
    CGRect frame = view.frame;
    frame.origin.y = bottom - frame.size.height;
    view.frame = frame;
}

+ (NSUInteger)computeContentLines:(NSString *)content withWidth:(CGFloat)width andFont:(UIFont *)font {
    CGSize constraint = CGSizeMake(width, 20000.0f);
    CGSize size = [content sizeWithFont:font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    
    return  (NSUInteger)(size.height / font.lineHeight);
}

+ (void)setUIViewController:(UIViewController *)controller defaultTitle:(UIView *)titleView {
    if (!titleView) {
        UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 85, 26)];
        logoView.image = [UIImage imageNamed:@"img_logo.png"];
        titleView = logoView;
    }
    controller.navigationItem.titleView = titleView;
}
@end
