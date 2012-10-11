//
//  Navigator.h
//  Neonan
//
//  Created by bigbear on 10/11/12.
//  Copyright (c) 2012 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#define __windows_height 460

typedef enum NavAnimation {
    None,
    From_Left,
    From_Right,
    From_Bottom,
    From_Top,
    Fade,
    Curl_Up,
    Curl_Down,
} NavAnimation;

@class Mediator;
@interface Navigator : NSObject {
    BOOL _animationStop;
    UIView *_from;
    CGRect _rect[5];
    
    UIView *_rootView;
    Mediator *_currentMediator;
    NSMutableArray *_mediators;
}

- (id)initWithRootMediator:(Mediator *)mediator withRootView:(UIView *)view;
- (void)pushMediator:(Mediator *)mediator withAnimation:(NavAnimation)animation;
- (Mediator *)popMediatorWithAnimation:(NavAnimation)animation;
- (Mediator *)popToRootMediatorWithAnimation:(NavAnimation)animation;

@end


@interface Mediator : UIView {
    
}
@property (nonatomic, assign) Navigator *navigator;

- (id)init;

- (void)pushMediator:(Mediator *)mediator withAnimation:(NavAnimation)animation;
- (Mediator *)popMediatorWithAnimation:(NavAnimation)animation;
- (Mediator *)popToRootMediatorWithAnimation:(NavAnimation)animation;


- (void)viewDidLoad;    // 页面被创建时被调用
- (void)viewDidAppear:(BOOL)animated;   // 页面进入窗口时被调用
- (void)viewDidDisappear:(BOOL)animated;    // 页面离开窗口时被调用
@end
