//
//  ShareEditController.h
//  Neonan
//
//  Created by capricorn on 12-11-6.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHSCore.h"

@interface ShareEditController : NNViewController <SHSOAuthDelegate>

@property (strong, nonatomic) id shareItem;

- (NSString *)getTrackUrl:(NSString *)source trackCB:(BOOL)trackCB site:(NSString *)site;
@end
