//
//  UnselectableTextView.m
//  Neonan
//
//  Created by capricorn on 12-10-22.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "UnselectableTextView.h"

@implementation UnselectableTextView

- (BOOL)canBecomeFirstResponder {
    return NO;
}

@end
