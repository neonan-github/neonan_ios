//
//  Constants.h
//  Neonan
//
//  Created by capricorn on 12-11-8.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UMengAppKey @"50c1b8545270150f81000018"

#define kSinaWeiboSource          @"weibo"
#define kSinaWeiboKey             @"2189669888"
#define kSinaWeiboSecret          @"b8301d46c49e7af13efebc42193665eb"
#define kSinaWeiboRedirectURI     @"http://www.neonan.com/auth/weibo/callback"

#define kTencentWeiboSource       @"qq_connect"
#define kTencentWeiboKey          @"801266115"
#define kTencentWeiboSecret       @"579fce9e5434e638c714d9261317f544"
#define kTencentWeiboRedirectURI  @"http://www.appchina.com/app/com.neonan.neoclient/"

#define kRenRenSource             @"xiaonei"
#define kRenRenKey                @"8e9fe88002b34076b52ce0ce9c8bead4"
#define kRenRenSecret             @"331e7f3a593f4c4abd9bc24e6a28f041"

typedef enum {
    SortTypeLatest = 0,
    SortTypeHotest
} SortType;

typedef enum {
    ValuationTypeNone = 0,
    ValuationTypeUp = 1,
    ValuationTypeDown = 2
} ValuationType;

typedef enum {
    ShowTypePush = 0,
    ShowTypeModal
} ShowType;

typedef enum {
    ThirdPlatformNoSpecified = 0,
    ThirdPlatformSina,
    ThirdPlatformTencent,
    ThirdPlatformRenRen
} ThirdPlatformType;

//MainController
#define MainSlideShowCount 6

