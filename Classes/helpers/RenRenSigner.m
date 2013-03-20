//
//  RenRenSigner.m
//  Bang
//
//  Created by capricorn on 12-12-28.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "RenRenSigner.h"

@interface RenRenSigner () <RenrenDelegate>

@property (nonatomic, strong) Renren *renren;

@end

@implementation RenRenSigner

+ (NNSigner *)signer {
    static NNSigner *_sharedSigner = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedSigner = [[RenRenSigner alloc] init];
    });
    
    return _sharedSigner;
}

- (id)init {
    self = [super init];
    if (self) {
        self.renren = [Renren sharedRenren];
    }
    
    return self;
}

- (Renren *)engine {
    return self.renren;
}

- (void)login {
    if (![_renren isSessionValid]) {
        [self logout];
        _renren.rootViewController = self.rootViewController;
        _renren.showType = self.showType;
		[_renren authorizationInNavigationWithPermisson:@[@"publish_share", @"photo_upload"] andDelegate:self];
	} else {
        _renren.renrenDelegate = self;
        [self renrenDidLogin:_renren];
    }
}

- (void)logout {
    [_renren logout:nil];
}

#pragma mark - RenrenDelegate methods

-(void)renrenDidLogin:(Renren *)renren {
    ROUserInfoRequestParam *requestParam = [[ROUserInfoRequestParam alloc] init];
	requestParam.fields = [NSString stringWithFormat:@"uid,name,sex,birthday,headurl"];
	
	[_renren getUsersInfo:requestParam andDelegate:self];
}

- (void)renren:(Renren *)renren loginFailWithError:(ROError*)error{
	if (self.failureBlock) {
        self.failureBlock(error);
    }
}

- (void)renren:(Renren *)renren requestDidReturnResponse:(ROResponse*)response {
    if ([response.param isMemberOfClass:[ROUserInfoRequestParam class]]) {
        NSArray *usersInfo = (NSArray *)(response.rootObject);
        ROUserResponseItem *userInfo = usersInfo[0];
        
        if (self.successBlock) {
            self.successBlock(userInfo.userId, userInfo.name, userInfo.headUrl);
        }
    }
}

- (void)renren:(Renren *)renren requestFailWithError:(ROError*)error{
	if (self.failureBlock) {
        self.failureBlock(error);
    }
}

@end
