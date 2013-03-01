//
//  SNAuthorizeViewController.h
//  HaHa
//
//  Created by capricorn on 12-12-17.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SinaWeibo.h"

@interface SNAuthorizeViewController : NNViewController

@property (nonatomic, assign) ShowType showType;

@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic, strong) SinaWeibo *weiboEngine;

@end
