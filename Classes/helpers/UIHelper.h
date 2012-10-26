//
//  UIHelper.h
//  Neonan
//
//  Created by capricorn on 12-10-18.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIHelper : NSObject
+ (void)fitScrollView:(UIScrollView *)scrollView withMaxHeight:(float)maxHeight;// make scrollview sizeToFit

+ (void)view:(UIView *)view alignBottomTo:(float)bottom;

+ (NSUInteger)computeContentLines:(NSString *)content withWidth:(CGFloat)width andFont:(UIFont *)font;

+ (void)setBackAction:(SEL)action forController:(UIViewController *)controller withImage:(UIImage *)image;

@end

@interface UIImage (UIImageUtil)

+ (UIImage *)imageFromFile:(NSString *)fileName;

@end
