//
//  BabyDetailController.h
//  Neonan
//
//  Created by capricorn on 12-10-22.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideShowView.h"
#import "FoldableTextBox.h"

@interface BabyDetailController : UIViewController<SlideShowViewDataSource, SlideShowViewDelegate,
FoldableTextBoxDelegate>

@end
