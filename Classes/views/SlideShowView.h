//
//  SlideShowView.h
//  Neonan
//
//  Created by capricorn on 12-10-12.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "ATPagingView.h"

@interface SlideShowView : ATPagingView
@property(nonatomic, retain) NSTimer *slideTimer;

- (void)startAutoScroll:(double)interval;
- (void)stopAutoScroll;
@end
