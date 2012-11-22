//
//  NNJSONRequestOperation.h
//  Neonan
//
//  Created by capricorn on 12-11-19.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "AFJSONRequestOperation.h"

@interface NNJSONRequestOperation : AFJSONRequestOperation
@property (assign, nonatomic) BOOL allowOfflineMode;

+ (NNJSONRequestOperation *)JSONRequestOperationWithRequest:(NSURLRequest *)urlRequest
                                                    success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                                    failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;
@end
