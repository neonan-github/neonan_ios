//
//  TencentSigner.h
//  Bang
//
//  Created by capricorn on 12-12-28.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "NNSigner.h"

#import "TCWBEngine.h"

@interface TencentSigner : NNSigner

@property (nonatomic, readonly) TCWBEngine *engine;

@end
