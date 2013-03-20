//
//  EncourageView.m
//  Neonan
//
//  Created by capricorn on 13-3-2.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "EncourageView.h"

@interface EncourageView ()

@property (nonatomic, strong, readonly) UIWindow *overlayWindow;

@property (nonatomic, weak) UIImageView *backgroundView;
@property (nonatomic, weak) UILabel *textLabel;

@end

@implementation EncourageView
@synthesize overlayWindow = _overlayWindow;

+ (EncourageView*)sharedView {
    static dispatch_once_t once;
    static EncourageView *sharedView;
    dispatch_once(&once, ^ { sharedView = [[EncourageView alloc] initWithFrame:CGRectMake(0, 0, 36, 36)]; });
    return sharedView;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        backgroundView.image = [UIImage imageFromFile:@"bg_encourage_circle.png"];
        self.backgroundView = backgroundView;
        [self addSubview:backgroundView];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.textLabel = textLabel;
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.textColor = HEXCOLOR(0x0096ff);
        textLabel.text = @"+3";
        [self addSubview:textLabel];
    }
    return self;
}

- (UIWindow *)overlayWindow {
    if(!_overlayWindow) {
        _overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _overlayWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _overlayWindow.backgroundColor = [UIColor clearColor];
        _overlayWindow.userInteractionEnabled = NO;
        _overlayWindow.windowLevel = UIWindowLevelStatusBar;
    }
    return _overlayWindow;
}

+ (void)displayScore:(NSInteger)score at:(CGPoint)center {
    EncourageView *sharedView = [EncourageView sharedView];
    if(!sharedView.superview) {
        [sharedView.overlayWindow addSubview:sharedView];
    }
    
    sharedView.x = center.x - sharedView.width / 2;
    sharedView.y = center.y - sharedView.height / 2;
    
    sharedView.overlayWindow.hidden = NO;
    
    sharedView.textLabel.text = [NSString stringWithFormat:@"+%d", score];
    
    CAAnimation *animation = [self createAnimation];
    animation.delegate = sharedView;
    [sharedView.layer addAnimation:animation forKey:@"displayAnimation"];
}

+ (CAAnimation *)createAnimation {
    CGFloat duration = 1.0f;
    
    CAKeyframeAnimation *zoomAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    zoomAnim.keyTimes = @[@0.0, @(0.5 * duration), @(0.7 * duration), @(duration)];
    zoomAnim.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.0, 0.0, 1.0)],
                        [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)],
                        [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)],
                        [NSValue valueWithCATransform3D:CATransform3DMakeScale(2.5, 2.5, 1.0)]];
    
    CAKeyframeAnimation *fadeAnim = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    fadeAnim.keyTimes = @[@0.0, @(0.5 * duration), @(0.7 * duration), @(duration)];
    fadeAnim.values = @[@0.1, @0.8, @1.0, @0.0];
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animationGroup.duration = duration;
    animationGroup.removedOnCompletion = NO;
    animationGroup.animations = @[zoomAnim, fadeAnim];
    animationGroup.fillMode = kCAFillModeForwards;
    
    return animationGroup;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag) {
        _overlayWindow.hidden = NO;
        [_overlayWindow removeFromSuperview];
        _overlayWindow = nil;
        
        [self.layer removeAllAnimations];
    }
}

@end
