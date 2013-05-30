//
//  PurchaseVIPController.m
//  Neonan
//
//  Created by capricorn on 13-3-8.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "PurchaseVIPController.h"

#import "PurchaseVIPCell.h"

#import "PurchaseManager.h"

#import "MKStoreManager.h"
#import "NSData+MKBase64.h"

#import <UIAlertView+Blocks.h>
#import <SVProgressHUD.h>

static const NSInteger kDefaultRetryTimes = 2;

@interface PurchaseVIPController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation PurchaseVIPController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"购买VIP";
    
    UIButton *navLeftButton = [UIHelper createLeftBarButton:@"icon_nav_close.png"];
    [navLeftButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navLeftButton];
    
    self.view.backgroundColor = DarkThemeColor;
}

- (void)cleanUp {
    self.tableView = nil;
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self itemTexts].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PurchaseVIPCell *cell = [[PurchaseVIPCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    NSString *text = [self itemTexts][indexPath.row];
    [cell setInfo:text priceRange:[text rangeOfString:@"\\d+" options:NSRegularExpressionSearch]];
    [cell prepareForTableView:tableView indexPath:indexPath];
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self buyVIP:[self productIds][indexPath.row]];
}

#pragma mark - Private methods

- (NSArray *)itemTexts {
    return @[@"年费会员 30 元", @"六个月会员 18 元", @"三个月会员 12 元", @"一个月会员 6 元"];
}

- (NSArray *)productIds {
    return @[@"com.neonan.Neonan.vip12months", @"com.neonan.Neonan.vip6months", @"com.neonan.Neonan.vip3months", @"com.neonan.Neonan.vip1month"];
}

- (NSDictionary *)productIdsMapping {
    return @{@"com.neonan.Neonan.vip12months": @"1", @"com.neonan.Neonan.vip6months": @"3", @"com.neonan.Neonan.vip3months": @"2", @"com.neonan.Neonan.vip1month": @"8"};
}

- (void)close {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)buyVIP:(NSString *)productId {
    [SVProgressHUD showWithStatus:@"购买中……" maskType:SVProgressHUDMaskTypeClear];
    [[PurchaseManager sharedManager] requestOrderId:[self productIdsMapping][productId] success:^(NSString *orderId) {
        [[MKStoreManager sharedManager] buyFeature:productId
                                        onComplete:^(NSString *purchasedFeature, NSData *purchasedReceipt, NSArray *availableDownloads) {
                                            [self onPurchaseSuccess:orderId receipt:purchasedReceipt];
                                        }
                                          onFailed:^(NSError *error) {
                                              [self onPurchaseFail:productId];
                                          }
                                       onCancelled:nil];
    } failure:^{
        [self onPurchaseFail:productId];
    }];
}

- (void)onPurchaseSuccess:(NSString *)orderId receipt:(NSData *)purchasedReceipt {
    [self syncPurchaseInfo:[orderId description] receipt:[purchasedReceipt base64EncodedString] retryTimesLeft:kDefaultRetryTimes];
    
//    RIButtonItem *okItem = [RIButtonItem item];
//    okItem.label = @"确定";
//    okItem.action = ^{
//        [self close];
//    };
//    
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
//                                                        message:@"购买成功"
//                                               cancelButtonItem:nil
//                                               otherButtonItems:okItem, nil];
//    [alertView show];
}

- (void)onPurchaseFail:(NSString *)productId {
    [SVProgressHUD dismiss];
    
    RIButtonItem *cancelItem = [RIButtonItem item];
    cancelItem.label = @"取消";
    
    RIButtonItem *retryItem = [RIButtonItem item];
    retryItem.label = @"重试";
    retryItem.action = ^{
        [self buyVIP:productId];
    };
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"购买失败"
                                               cancelButtonItem:cancelItem
                                               otherButtonItems:retryItem, nil];
    [alertView show];
}

- (void)syncPurchaseInfo:(NSString *)orderId receipt:(NSString *)purchasedReceipt retryTimesLeft:(NSInteger)retryTimesLeft {
    [SVProgressHUD showWithStatus:@"正在验证购买信息" maskType:SVProgressHUDMaskTypeClear];
    
    [[PurchaseManager sharedManager] syncPurchaseInfo:orderId
                                              receipt:(NSString *)purchasedReceipt
                                              success:^{
                                                  RIButtonItem *okItem = [RIButtonItem item];
                                                  okItem.label = @"确定";
                                                  okItem.action = ^{
                                                      [self close];
                                                  };
                                                  
                                                  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                                                      message:@"验证成功"
                                                                                             cancelButtonItem:nil
                                                                                             otherButtonItems:okItem, nil];
                                                  [alertView show];
                                              }
                                              failure:^(ResponseError *error){
                                                  DLog(@"retry times:%d", retryTimesLeft);
                                                  
                                                  if (error.errorCode == ERROR_BAD_ORDER) {
                                                      [UIHelper alertWithMessage:@"无效的购买信息"];
                                                      [SVProgressHUD dismiss];
                                                  } else if (retryTimesLeft == 0){
                                                      RIButtonItem *cancelItem = [RIButtonItem item];
                                                      cancelItem.label = @"取消";
                                                      cancelItem.action = ^{
                                                          [self close];
                                                      };
                                                      
                                                      RIButtonItem *retryItem = [RIButtonItem item];
                                                      retryItem.label = @"重试";
                                                      retryItem.action = ^{
                                                          [self syncPurchaseInfo:orderId receipt:purchasedReceipt retryTimesLeft:kDefaultRetryTimes];
                                                      };
                                                      
                                                      UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"验证失败"
                                                                                                          message:@"可能是网络问题，无需重新购买。选择“重试”，立即重新验证；选择“取消”，将之后自动验证。"
                                                                                                 cancelButtonItem:cancelItem
                                                                                                 otherButtonItems:retryItem, nil];
                                                      [alertView show];
                                                  } else {
                                                      [self syncPurchaseInfo:orderId receipt:purchasedReceipt retryTimesLeft:retryTimesLeft - 1];
                                                  }
                                              }];
}


@end
