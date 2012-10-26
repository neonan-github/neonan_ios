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

+ (void)setBackAction:(SEL)action forController:(UIViewController *)controller withImage:(UIImage *)image {
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    [backButton setBackgroundImage:image forState:UIControlStateNormal];
    [backButton addTarget:controller action:action forControlEvents:UIControlEventTouchUpInside];
    controller.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

@end

@implementation UIImage (UIImageUtil)

+ (UIImage *)imageFromFile:(NSString *)fileName {
    NSArray *splits = [fileName componentsSeparatedByString:@"."];
    NSString *fileLocation = [[NSBundle mainBundle] pathForResource:[splits objectAtIndex:0] ofType:[splits objectAtIndex:1]];
    NSData *imageData = [NSData dataWithContentsOfFile:fileLocation];
    return [UIImage imageWithData:imageData];
}

@end
