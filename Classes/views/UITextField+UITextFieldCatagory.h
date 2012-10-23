//
//  UITextField+UITextFieldCatagory.h
//  Neonan
//
//  Created by capricorn on 12-10-23.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (UITextFieldCatagory)
@property (nonatomic, copy) NSNumber *leftMargin;

- (CGRect)textRectForBounds:(CGRect)bounds;
- (CGRect)editingRectForBounds:(CGRect)bounds;
@end
