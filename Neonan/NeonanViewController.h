//
//  NeonanViewController.h
//  Neonan
//
//  Created by bigbear on 10/11/12.
//  Copyright (c) 2012 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Navigator.h"

@interface NeonanViewController : UIViewController {
    Navigator *_nav;
}

- (void)launch;
- (void)enterBackground;
- (void)enterForeground;
- (void)exit;

@end
