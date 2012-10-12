//
//  SlideShowView.m
//  Neonan
//
//  Created by capricorn on 12-10-12.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "SlideShowView.h"

@implementation SlideShowView
@synthesize slideTimer;

- (void)update
{
    if (!_scrollView) {
        return;
    }
    
    const float pageWidth = self.frame.size.width;
    CGPoint pt = _scrollView.contentOffset;
    float x;
    if(self.currentPageIndex == self.pageCount - 1){
        x = 0;
    } else {
        x = pt.x + pageWidth;
    }
    
    [_scrollView scrollRectToVisible:CGRectMake(x, 0, pageWidth, self.frame.size.height) animated:YES];
}

- (void)startAutoScroll:(double)interval {
    if (!self.slideTimer || self.slideTimer.timeInterval != interval) {
        [self.slideTimer invalidate];
        self.slideTimer = nil;
    
        self.slideTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                 target:self
                                               selector:@selector(update)
                                               userInfo:nil
                                                repeats:YES];
    }
}

- (void)stopAutoScroll {
    [self.slideTimer invalidate];
    self.slideTimer = nil;
}

- (void)dealloc {
    [self stopAutoScroll];
    [super dealloc];
}

@end
