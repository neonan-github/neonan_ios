//
//  RRAuthorizeViewController.h
//  bang_ipad
//
//  Created by capricorn on 13-2-26.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "NNViewController.h"

#import "Renren.h"

@interface RRAuthorizeViewController : NNViewController

@property (nonatomic, assign) ShowType showType;

@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic, strong) Renren *renrenEngine;
@property (nonatomic, strong) ROResponse *response;

@end
