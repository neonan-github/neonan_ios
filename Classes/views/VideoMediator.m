//
//  VideoMediator.m
//  Neonan
//
//  Created by capricorn on 12-10-12.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "VideoMediator.h"
#import <MediaPlayer/MediaPlayer.h>

@interface VideoMediator () {
    MPMoviePlayerController *_streamPlayer;
}
@end

@implementation VideoMediator

- (void)viewDidLoad
{
    UILabel *navBar = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)] autorelease];
    navBar.text = @"自定义导航栏";
    navBar.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
    navBar.textAlignment = NSTextAlignmentCenter;
    navBar.userInteractionEnabled = YES;
    [self addSubview:navBar];
    
    UIButton *back = [[[UIButton alloc] initWithFrame:CGRectMake(10, 5, 60, 30)] autorelease];
    back.layer.cornerRadius = 10;
    [back setBackgroundColor:[UIColor grayColor]];
    [back setTitle:@"返回" forState:UIControlStateNormal];
    [back setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [back setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:back];
    
    NSURL *streamURL = [NSURL URLWithString:@"http://www.thumbafon.com/code_examples/video/segment_example/prog_index.m3u8"];
    _streamPlayer = [[MPMoviePlayerController alloc] initWithContentURL:streamURL];    
    _streamPlayer.view.frame = CGRectMake(0, 40, 320, 420);
    _streamPlayer.controlStyle = MPMovieControlStyleEmbedded;
    [self addSubview:_streamPlayer.view];
    [_streamPlayer play];
}

- (void)dealloc
{
    [_streamPlayer release];
    [super dealloc];
}

- (void)back
{
    [self popMediatorWithAnimation:From_Left];
}

- (void)viewDidAppear:(BOOL)animated
{

}

- (void)viewDidDisappear:(BOOL)animated
{
    
}

@end
