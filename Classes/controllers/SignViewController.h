//
//  SignViewController.h
//  Neonan
//
//  Created by Wu Yunpeng on 13-6-2.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "NNViewController.h"

typedef enum {
    SignTypeIn = 0,
    SignTypeUp
} SignType;

typedef void(^SignSuccessBlock)(NSString *token);

@interface SignViewController : NNViewController

@property (copy, nonatomic) SignSuccessBlock success;

- (id)initWithType:(SignType)type;

@end
