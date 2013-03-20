//
//  ShareEditController.h
//  Neonan
//
//  Created by capricorn on 12-11-6.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NNSharer.h"

@interface ShareEditController : NNViewController

@property (nonatomic, strong) NNSharer *sharer;

@property (nonatomic, copy) NSString *shareText;
@property (nonatomic, copy) NSString *shareUrl;
@property (nonatomic, strong) UIImage *shareImage;

@end
