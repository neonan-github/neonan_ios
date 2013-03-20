//
//  SinaSigner.h
//  Bang
//
//  Created by capricorn on 12-12-28.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "NNSigner.h"

#import "SinaWeibo.h"

@interface SinaSigner : NNSigner

@property (nonatomic, readonly) SinaWeibo *engine;

@end
