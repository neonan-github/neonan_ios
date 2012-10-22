//
//  MainController.h
//  Neonan
//
//  Created by capricorn on 12-10-22.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideShowView.h"

@interface MainController : UIViewController <SlideShowViewDataSource, SlideShowViewDelegate,
UITableViewDataSource, UITableViewDelegate>

@end
