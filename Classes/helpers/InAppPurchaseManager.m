//
//  InAppPurchaseManager.m
//  Neonan
//
//  Created by capricorn on 13-3-6.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "InAppPurchaseManager.h"

@interface InAppPurchaseManager () <SKProductsRequestDelegate>

//@property (nonatomic, )

@end

@implementation InAppPurchaseManager

+ (InAppPurchaseManager *)sharedManager {
    static InAppPurchaseManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[InAppPurchaseManager alloc] init];
    });
    
    return _sharedManager;
}

- (void)requestProUpgradeProductData
{
    NSSet *productIdentifiers = [NSSet setWithObject:@"com.neonan.Neonan.vip1" ];
    SKProductsRequest * productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
    
    // we will release the request object in the delegate callback
}

#pragma mark -
#pragma mark SKProductsRequestDelegate methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *products = response.products;
    [products enumerateObjectsUsingBlock:^(SKProduct *product, NSUInteger idx, BOOL *stop) {
        NSLog(@"Product title: %@" , product.localizedTitle);
        NSLog(@"Product description: %@" , product.localizedDescription);
        NSLog(@"Product price: %@" , product.price);
        NSLog(@"Product id: %@" , product.productIdentifier);
    }];
    
    for (NSString *invalidProductId in response.invalidProductIdentifiers)
    {
        NSLog(@"Invalid product id: %@" , invalidProductId);
    }
    
    // finally release the reqest we alloc/init’ed in requestProUpgradeProductData
//    [productsRequest release];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerProductsFetchedNotification object:self userInfo:nil];
}

@end
