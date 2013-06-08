//
//  InfoEditController.h
//  Neonan
//
//  Created by capricorn on 13-3-8.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "NNViewController.h"

@interface InfoEditViewController : NNViewController

@property (nonatomic, strong) UIImage *avatarImage;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) void (^infoChangedBlock)(UIImage *avatarImage, NSString *name);

@end
