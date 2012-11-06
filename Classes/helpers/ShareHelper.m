//
//  ShareHelper.m
//  Neonan
//
//  Created by capricorn on 12-11-6.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "ShareHelper.h"
#import "SHSCore.h"
#import "SHSRedirectSharer.h"
#import "ShareEditController.h"

@interface ShareHelper ()
@property (strong, nonatomic) NSMutableArray *menuItems;

- (void)loadConfig;
@end

@implementation ShareHelper

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super init];
    if (self) {
        _rootViewController=rootViewController;
        _menuItems=[[NSMutableArray alloc] init];
        [self loadConfig];
    }
    return self;
}

- (void)loadConfig
{
    NSDictionary *config=[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ServiceConfig" ofType:@"plist"]];
    NSArray *services=[config objectForKey:@"OAuthServices"];
    NSArray *actions=[config objectForKey:@"Actions"];
    NSArray *redirectServices=[config objectForKey:@"RedirectServices"];
    
    for(int i=0; i<[services count];i++)
    {
        NSDictionary *dict=[services objectAtIndex:i];
        id<SHSOAuthSharerProtocol> sharer=nil;
        OAuthType type=[[dict objectForKey:@"oauthType"] intValue];
        switch (type) {
            case OAuthTypeOAuth1WithHeader:
            case OAuthTypeOAuth1WithQueryString:
            {
                SHSOAuth1Sharer * serviceSharer=[[NSClassFromString([dict objectForKey:@"name"]) alloc] init];
                serviceSharer.key=[dict objectForKey:@"key"];
                serviceSharer.name=[dict objectForKey:@"title"];
                serviceSharer.requestTokenURL=[dict objectForKey:@"requestTokenURL"];
                serviceSharer.autherizeURL=[dict objectForKey:@"authorizeURL"];
                serviceSharer.accessTokenURL=[dict objectForKey:@"accessTokenURL"];
                serviceSharer.callbackURL=[dict objectForKey:@"callbackURL"];
//                serviceSharer.rootViewController=_rootViewController;
//                serviceSharer.delegate=self;
                serviceSharer.signatureProvider=[[OAHMAC_SHA1SignatureProvider alloc] init];
                serviceSharer.oauthType=type;
                sharer=serviceSharer;
            }
                break;
            case OAuthTypeOAuth2:
            {
                SHSOAuth2Sharer * serviceSharer=[[NSClassFromString([dict objectForKey:@"name"]) alloc] init];
                serviceSharer.key=[dict objectForKey:@"key"];
                serviceSharer.name=[dict objectForKey:@"title"];
                serviceSharer.autherizeURL=[dict objectForKey:@"authorizeURL"];
                serviceSharer.callbackURL=[dict objectForKey:@"callbackURL"];
//                serviceSharer.rootViewController=_rootViewController;
//                serviceSharer.delegate=self;
                serviceSharer.oauthType=type;
                sharer=serviceSharer;
            }
                break;
            default:
                break;
        }
        
        [_menuItems addObject:sharer];
    }
    
    for(int j=0;j<[actions count];j++)
    {
        NSDictionary *dict=[actions objectAtIndex:j];
        NSString *name=[dict objectForKey:@"name"];
        NSString *description=[dict objectForKey:@"description"];
        id<SHSActionProtocol> action=[[NSClassFromString([NSString stringWithFormat:@"SHS%@Action",name]) alloc] init];
        action.description=description;
//        action.rootViewController=_rootViewController;
        [_menuItems addObject:action];
    }
    
    for(NSDictionary *dict in redirectServices)
    {
        SHSRedirectSharer *redirectSharer=[[SHSRedirectSharer alloc] init];
        redirectSharer.title=[dict objectForKey:@"title"];
        redirectSharer.name=[dict objectForKey:@"name"];
        [_menuItems addObject:redirectSharer];
    }
}


- (void)showShareView
{
    UIActionSheet *actionSheet=[[UIActionSheet alloc] initWithTitle:@"分享到" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    
    for(id item in _menuItems)
    {
        if([item conformsToProtocol:@protocol(SHSActionProtocol)]) {
            [actionSheet addButtonWithTitle:((id<SHSActionProtocol>)item).description];
        } else if([item conformsToProtocol:@protocol(SHSOAuthSharerProtocol)]) {
            [actionSheet addButtonWithTitle:((id<SHSOAuthSharerProtocol>)item).name];
        } else {
            [actionSheet addButtonWithTitle:((SHSRedirectSharer *)item).title];
        }
    }
    
    [actionSheet addButtonWithTitle:@"取消"];
    [actionSheet setCancelButtonIndex:actionSheet.numberOfButtons-1];
    [actionSheet showInView:_rootViewController.view];
}

#pragma mark- UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==actionSheet.numberOfButtons-1)
        return;
    
    id item = [_menuItems objectAtIndex:buttonIndex];
    
    
    if([item conformsToProtocol:@protocol(SHSOAuthSharerProtocol)])  {
        ShareEditController *controller = [[ShareEditController alloc] init];
        controller.shareItem = item;
        [item performSelector:@selector(setRootViewController:) withObject:controller];
        [item performSelector:@selector(setDelegate:) withObject:controller];
        [_rootViewController.navigationController pushViewController:controller animated:YES];
    } else if([item conformsToProtocol:@protocol(SHSActionProtocol)]) {
        [item performSelector:@selector(setRootViewController:) withObject:_rootViewController];
        [((id<SHSActionProtocol>)item) setDescription:@"description"];
        [((id<SHSActionProtocol>)item) setSharedUrl:@"http://www.google.com"];
        [((id<SHSActionProtocol>)item) sendAction:@"testtest"];
    } else {
    }
    
 
    
//    if(!self.sharedText || [self.sharedText isEqualToString:@""])
//    {
//        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"必须指定要分享的内容" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
//        [alert show];
//        return;
//    }
//    
//    if([item conformsToProtocol:@protocol(SHSOAuthSharerProtocol)])  {
//        [((id<SHSOAuthSharerProtocol>)item) setSharedUrl:self.sharedURL];
//        [((id<SHSOAuthSharerProtocol>)item) shareText:self.sharedText];
//            
//    } else if([item conformsToProtocol:@protocol(SHSActionProtocol)]) {
//        [((id<SHSActionProtocol>)item) setSharedUrl:self.sharedURL];
//        [((id<SHSActionProtocol>)item) sendAction:self.sharedText];
//    } else {
//    }
}

//-(NSString *)getTrackUrl:(NSString *)source trackCB:(BOOL)trackCB site:(NSString *)site
//{
//    NSString *pattern = @"http://www.bshare.cn/burl?url=%@&publisherUuid=%@&site=%@";
//    NSString *uuid = PUBLISHER_UUID;
//    if (!uuid) {
//        uuid = @"";
//    }
//    if (!site){
//        site = @"";
//    }
//    if (source && trackCB) {
//        return [NSString stringWithFormat:pattern,source,uuid,site];
//    }
//    return [NSString stringWithString:source];
//}

@end
