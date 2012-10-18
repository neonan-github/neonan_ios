//
//  UIHelper.h
//  Neonan
//
//  Created by capricorn on 12-10-18.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIHelper : NSObject
+ (void)fitScrollView:(UIScrollView *)scrollView withMaxHeight:(float)maxHeight;// make scrollview sizeToFit

+ (void)view:(UIView *)view alignBottomTo:(float)bottom;

+ (void)makeTextViewAlignCenter:(UITextView *)tv;
@end
