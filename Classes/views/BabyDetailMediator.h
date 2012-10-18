//
//  BabyDetailMediator.h
//  Neonan
//
//  Created by capricorn on 12-10-17.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "Navigator.h"
#import "SlideShowView.h"

@interface BabyDetailMediator : Mediator<SlideShowViewDataSource, SlideShowViewDelegate>
@property (nonatomic, copy) NSString *description;
@end
