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
    RequestTypeRefresh = 0,
    RequestTypeAppend
} RequestType;

typedef enum {
    ContentTypeSlide = 0,
    ContentTypeArticle,
    ContentTypeVideo
} ContentType;

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

typedef enum {
    EncourageScoreCommon = 3,
    EncourageScoreComment = 2,
    EncourageScoreLogin = 1,
    EncourageScoreSignUp = 8,
    EncourageScoreShare = 2
} EncourageScore;

typedef enum {
    VIPLevel1 = 1,
    VIPLevel3 = 3,
    VIPLevel6 = 6,
    VIPLevel12 = 12
} VIPLevel;

//MainController
#define MainSlideShowCount 6

FOUNDATION_EXPORT NSString *const kPathSlideShow;
FOUNDATION_EXPORT NSString *const kPathWorkList;
FOUNDATION_EXPORT NSString *const kPathWorkInfo;
FOUNDATION_EXPORT NSString *const kPathNearWork;
FOUNDATION_EXPORT NSString *const kPathCommentList;
FOUNDATION_EXPORT NSString *const kPathPublishComment;
FOUNDATION_EXPORT NSString *const kPathPeopleList;
FOUNDATION_EXPORT NSString *const kPathPeopleInfo;
FOUNDATION_EXPORT NSString *const kPathNearPeople;
FOUNDATION_EXPORT NSString *const kPathPeopleVote;

FOUNDATION_EXPORT NSString *const kPathNeoNanSignUp;
FOUNDATION_EXPORT NSString *const kPathNeoNanLogin;
FOUNDATION_EXPORT NSString *const kPath3rdLogin;
FOUNDATION_EXPORT NSString *const kPathCreateOrder;

