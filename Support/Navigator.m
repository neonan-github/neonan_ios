//
//  Navigator.m
//  Neonan
//
//  Created by bigbear on 10/11/12.
//  Copyright (c) 2012 neonan. All rights reserved.
//

#import "Navigator.h"
#import <QuartzCore/QuartzCore.h>

@implementation Navigator

- (id)initWithRootMediator:(Mediator *)mediator withRootView:(UIView *)view
{
    self = [super init];
    if (self) {
        _from = nil;
        _animationStop = YES;
        _rect[0] = CGRectMake(0, 0, 320, __windows_height);
        _rect[1] = CGRectMake(0, -460, 320, __windows_height);
        _rect[2] = CGRectMake(320, 0, 320, __windows_height);
        _rect[3] = CGRectMake(0, 460, 320, __windows_height);
        _rect[4] = CGRectMake(-320, 0, 320, __windows_height);
        
        _rootView = [view retain];
        [_rootView addSubview:mediator];
        
        _mediators = [[NSMutableArray alloc] init];
        [mediator setNavigator:self];
        [_mediators addObject:mediator];
        _currentMediator = mediator;
    }
    return self;
}

- (void)dealloc
{
    [_rootView release];
    [_mediators removeAllObjects];
    [_mediators release];
    [super dealloc];
}

- (void)pageAnimationStop
{
    _animationStop = YES;
    _from.frame = _rect[0];
    [_from removeFromSuperview];
    _from = nil;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self pageAnimationStop];
}

- (void)pageAnimation:(NavAnimation)animation from:(UIView *)from to:(UIView *)to inView:(UIView *)inView
{
    if (!_animationStop) {
        return ;
    }
    _from = from;
    _animationStop = NO;
    if (animation == None) {
        _animationStop = YES;
        [from removeFromSuperview];
        [inView addSubview:to];
    } else if (animation == From_Left) {
        to.frame = _rect[4];
        [inView addSubview:to];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.35];
//        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDidStopSelector:@selector(pageAnimationStop)];
        [UIView setAnimationDelegate:self];
        from.frame = _rect[2];
        to.frame = _rect[0];
        [UIView commitAnimations];
    } else if (animation == From_Right) {
        to.frame = _rect[2];
        [inView addSubview:to];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.35];
//        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDidStopSelector:@selector(pageAnimationStop)];
        [UIView setAnimationDelegate:self];
        from.frame = _rect[4];
        to.frame = _rect[0];
        [UIView commitAnimations];
    } else if (animation == From_Top) {
        to.frame = _rect[1];
        [inView addSubview:to];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.35];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDidStopSelector:@selector(pageAnimationStop)];
        [UIView setAnimationDelegate:self];
        if (to == nil) {
            from.frame = _rect[3];
        }
        to.frame = _rect[0];
        [UIView commitAnimations];
    } else if (animation == From_Bottom) {
        to.frame = _rect[3];
        [inView addSubview:to];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.35];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDidStopSelector:@selector(pageAnimationStop)];
        [UIView setAnimationDelegate:self];
        if (to == nil) {
            from.frame = _rect[1];
        }
        to.frame = _rect[0];
        [UIView commitAnimations];
    } else if (animation == Fade) {
        CATransition *animation = [CATransition animation];
        [animation setDuration:0.35f];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
        [animation setType:kCATransitionFade];
        [animation setDelegate:self];
        [inView.layer addAnimation:animation forKey:nil];
        [from removeFromSuperview];
        [inView addSubview:to];
    } else if (animation == Curl_Up) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:1.0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:inView cache:YES];
        [UIView setAnimationDidStopSelector:@selector(pageAnimationStop)];
        [from removeFromSuperview];
        [inView addSubview:to];
        [UIView commitAnimations];
    } else if (animation == Curl_Down) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:1.0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:inView cache:YES];
        [UIView setAnimationDidStopSelector:@selector(pageAnimationStop)];
        [from removeFromSuperview];
        [inView addSubview:to];
        [UIView commitAnimations];
    }
}

- (void)pushMediator:(Mediator *)mediator withAnimation:(NavAnimation)animation
{
    [mediator setNavigator:self];
    [_mediators addObject:mediator];
    [self pageAnimation:animation from:_currentMediator to:mediator inView:_rootView];
    _currentMediator = mediator;
}

- (Mediator *)popMediatorWithAnimation:(NavAnimation)animation
{
    Mediator *to = nil;
    if (_mediators.count > 1) {
        to = [_mediators objectAtIndex:_mediators.count - 2];
        [self pageAnimation:animation from:_currentMediator to:to inView:_rootView];
        [_mediators removeLastObject];
        _currentMediator = to;
    }
    return to;
}

- (Mediator *)popToRootMediatorWithAnimation:(NavAnimation)animation
{
    Mediator *to = nil;
    if (_mediators.count > 1) {
        to = [_mediators objectAtIndex:0];
        [self pageAnimation:animation from:_currentMediator to:to inView:_rootView];
        [_mediators removeObjectsInRange:NSMakeRange(1, _mediators.count - 1)];
        _currentMediator = to;
    }
    return to;
}

@end




@implementation Mediator
@synthesize navigator = _navigator;

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 320, __windows_height)];
    if (self) {
        [self viewDidLoad];
    }
    return self;
}

- (void)pushMediator:(Mediator *)mediator withAnimation:(NavAnimation)animation
{
    [self viewDidDisappear:(animation != None)];
    [_navigator pushMediator:mediator withAnimation:animation];
    [mediator viewDidAppear:(animation != None)];
}

- (Mediator *)popMediatorWithAnimation:(NavAnimation)animation
{
    [self viewDidDisappear:(animation != None)];
    Mediator *to = [_navigator popMediatorWithAnimation:animation];
    [to viewDidAppear:(animation != None)];
    return to;
}

- (Mediator *)popToRootMediatorWithAnimation:(NavAnimation)animation
{
    [self viewDidDisappear:(animation != None)];
    Mediator *to = [_navigator popToRootMediatorWithAnimation:animation];
    [to viewDidAppear:(animation != None)];
    return to;
}

- (void)viewDidLoad
{
    
}

- (void)viewDidAppear:(BOOL)animated
{
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    
}

@end
