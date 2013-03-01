//
//  RenRenSigner.h
//  Bang
//
//  Created by capricorn on 12-12-28.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NNSigner.h"

#import "Renren.h"

@interface RenRenSigner : NNSigner

@property (nonatomic, readonly) Renren *engine;

@end
