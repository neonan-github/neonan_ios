//
//  BabyListMediator.h
//  Neonan
//
//  Created by capricorn on 12-10-15.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "Navigator.h"
#import "SlideShowView.h"

@interface BabyListMediator : Mediator <SlideShowViewDataSource, SlideShowViewDelegate,
    UITableViewDataSource, UITableViewDelegate>

@end
