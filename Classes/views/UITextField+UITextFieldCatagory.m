//
//  UITextField+UITextFieldCatagory.m
//  Neonan
//
//  Created by capricorn on 12-10-23.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "UITextField+UITextFieldCatagory.h"
#import <objc/runtime.h>

static char leftMarginKey;

@implementation UITextField (UITextFieldCatagory)
@dynamic leftMargin;

- (void)setLeftMargin:(NSNumber *)margin {
    [self willChangeValueForKey:@"leftMargin"];
    objc_setAssociatedObject(self, &leftMarginKey,
                             margin,
                             OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self didChangeValueForKey:@"leftMargin"];
}

- (NSNumber *)leftMargin {
    NSNumber *margin = objc_getAssociatedObject(self, &leftMarginKey);
    if(!margin) {
        return 0;
    }
    return margin;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    CGFloat leftMargin = self.leftMargin.floatValue;
    CGRect inset = CGRectMake(bounds.origin.x + leftMargin, bounds.origin.y, bounds.size.width - leftMargin, bounds.size.height);
    return inset;
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    CGFloat leftMargin = self.leftMargin.floatValue;
    CGRect inset = CGRectMake(bounds.origin.x + leftMargin, bounds.origin.y, bounds.size.width - leftMargin, bounds.size.height);
    return inset;
}

@end
