//
//  NNHttpClient.h
//  Neonan
//
//  Created by capricorn on 12-11-1.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <AFNetworking.h>

@interface NNHttpClient : AFHTTPClient

+ (NNHttpClient *)sharedClient;

@end
