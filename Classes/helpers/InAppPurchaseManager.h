//
//  InAppPurchaseManager.h
//  Neonan
//
//  Created by capricorn on 13-3-6.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#define kInAppPurchaseManagerProductsFetchedNotification @"kInAppPurchaseManagerProductsFetchedNotification"

@interface InAppPurchaseManager : NSObject

+ (InAppPurchaseManager *)sharedManager;

- (void)requestProUpgradeProductData;

@end
