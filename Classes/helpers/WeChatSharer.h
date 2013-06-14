//
//  WeChatSharer.h
//  Bang
//
//  Created by capricorn on 13-1-16.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "NNSharer.h"

#import "WXApi.h"

@interface WeChatSharer : NNSharer <WXApiDelegate>

@property (nonatomic, assign) enum WXScene scene;

@end
