//
//  SplashViewController.h
//  Neonan
//
//  Created by capricorn on 13-3-11.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MottoModel.h"  

@interface SplashViewController : NNViewController

@property (nonatomic, copy) void ((^done)(MottoModel *motto));

@end
