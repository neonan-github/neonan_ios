//
//  VIPManager.h
//  Neonan
//
//  Created by capricorn on 13-3-8.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PurchaseManager : NSObject

+ (PurchaseManager *)sharedManager;

- (void)requestOrderId:(NSString *)productId success:(void (^)(NSString *orderId))success failure:(void (^)())failure;
- (void)syncPurchaseInfo:(NSString *)orderId receipt:(NSString *)purchasedReceipt success:(void (^)())success failure:(void (^)())failure;
- (void)commitUnnotifiedInfo:(void (^)())done;

@end
