//
//  GalleryContainerMediator.h
//  Neonan
//
//  Created by capricorn on 12-10-11.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "Navigator.h"
#import "SlideShowView.h"
#import "ATPagingView.h"

@interface GalleryContainerMediator : Mediator <ATPagingViewDelegate, UITableViewDataSource, UITableViewDelegate>

@end
