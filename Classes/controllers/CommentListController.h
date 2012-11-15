//
//  CommentListControllerViewController.h
//  Neonan
//
//  Created by capricorn on 12-10-22.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HPGrowingTextView.h>
#import "ArticleDetailModel.h"

@interface CommentListController: UIViewController<UITableViewDataSource, UITableViewDelegate,
HPGrowingTextViewDelegate>

@property (strong, nonatomic) ArticleDetailModel *articleInfo;

@end
