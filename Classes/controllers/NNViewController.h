//
//  NNViewController.h
//  Bang
//
//  Created by capricorn on 12-12-21.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"

@interface NNViewController : UIViewController 

@property (nonatomic, assign, getter = isVisible) BOOL visible;

- (void)cleanUp;

@end
