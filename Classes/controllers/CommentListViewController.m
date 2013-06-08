//
//  CommentListControllerViewController.m
//  Neonan
//
//  Created by capricorn on 12-10-22.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "CommentListViewController.h"
#import "NNNavigationController.h"

#import "CommentListModel.h"
#import "ShareHelper.h"

#import "CommentBox.h"
#import "CommentCell.h"

#import "MarqueeLabel.h"

#import <MBProgressHUD.h>
#import <SVPullToRefresh.h>

#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f
#define COMMENT_BOX_ORIGINAL_HEIGHT 40.0f

static const NSUInteger kRequestCount = 20;
static NSString * const kRequestCountString = @"20";

@interface CommentListViewController () <UITableViewDataSource, UITableViewDelegate,
HPGrowingTextViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *titleLineView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet CommentBox *commentBox;

@property (nonatomic, strong) CommentListModel *dataModel;

@end

@implementation CommentListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    MarqueeLabel *titleLabel = [UIHelper createNavMarqueeLabel];
    titleLabel.tapToScroll = YES;
    titleLabel.text = self.articleInfo.title;
    self.navigationItem.titleView = titleLabel;
    
    UIButton* backButton = [UIHelper createLeftBarButton:@"icon_nav_back.png"];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    self.view.backgroundColor = DarkThemeColor;
    
    self.tableView.backgroundColor = DarkThemeColor;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView addPullToRefreshWithActionHandler:^{
        // refresh data
        // call [tableView.pullToRefreshView stopAnimating] when done
        [self requestForComments:_articleInfo.contentId withRequestType:RequestTypeRefresh];
    }];
    self.tableView.pullToRefreshView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        // add data to data source, insert new cells into table view
        [self requestForComments:_articleInfo.contentId withRequestType:RequestTypeAppend];
    }];
    self.tableView.infiniteScrollingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    self.tableView.showsInfiniteScrolling = NO;
    
    [self.commentBox.countButton setTitle:[NSString stringWithFormat:@"%u", self.articleInfo.commentNum]
                                 forState:UIControlStateNormal];
    self.commentBox.countButton.enabled = NO;
    
    [self.commentBox.doneButton addTarget:self action:@selector(publish:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)cleanUp {
    self.titleLineView = nil;
    
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
    self.tableView = nil;
    
    self.commentBox = nil;
    
    self.dataModel = nil;
}

#pragma mark - UIViewController life cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    CGRect frame = self.commentBox.frame;
//    frame.origin.y = self.view.bounds.size.height - frame.size.height;
//    self.commentBox.frame = frame;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self.tableView triggerPullToRefresh];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
}

#pragma mark － UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataModel.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[CommentCell alloc] initWithReuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    CommentItem *comment = [_dataModel.items objectAtIndex:indexPath.row];
    cell.commentLabel.text = comment.content;
    cell.userNameLabel.text = comment.visitor;
    cell.timeLabel.text = comment.date;
    [cell setVip:comment.isVip andLevel:comment.level];
    
    return cell;
    
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentItem *comment = [_dataModel.items objectAtIndex:indexPath.row];
    UIFont *font = [CommentCell getCommentFont];
    
    CGSize constraint = CGSizeMake([CommentCell getContentWidth:CompatibleScreenWidth], 20000.0f);
    
    CGSize size = [comment.content sizeWithFont:font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    
    return MAX(size.height + [CommentCell getFixedPartHeight], 70);
}

#pragma mark - Keyboard events handle

//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note {
//    _commentBox.rightView = nil;
    
    // get keyboard size and loctaion
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
	// get a rect for the textView frame
	CGRect containerFrame = self.commentBox.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    
    CGRect tableFrame = self.tableView.frame;
    tableFrame.size.height = containerFrame.origin.y - tableFrame.origin.y;
    
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
	
	// set views with new info
	self.commentBox.frame = containerFrame;
    self.tableView.frame = tableFrame;
	
	// commit animations
	[UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
//    _commentBox.rightView = _commentButton;
    
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
	
	// get a rect for the textView frame
	CGRect containerFrame = self.commentBox.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
    CGRect tableFrame = self.tableView.frame;
    tableFrame.size.height = self.view.bounds.size.height - COMMENT_BOX_ORIGINAL_HEIGHT - tableFrame.origin.y;
	
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
	// set views with new info
	self.commentBox.frame = containerFrame;
    self.tableView.frame = tableFrame;
	
	// commit animations
	[UIView commitAnimations];
}

#pragma mark - Prviate UI related

- (void)updateTableView:(RequestType)requestType {
    [_tableView reloadData];
    if (requestType == RequestTypeRefresh) {
        [_tableView.pullToRefreshView stopAnimating];
    } else {
        [_tableView.infiniteScrollingView stopAnimating];
    }
    
    _tableView.showsInfiniteScrolling = [_dataModel totalCount] > [_dataModel items].count;
}

#pragma mark - Private Request methods

- (void)requestForComments:(NSString *)contentId withRequestType:(RequestType)requestType {
    NSUInteger offset = (requestType == RequestTypeRefresh ? 0 : [_dataModel items].count);
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:contentId, @"content_id",
                                [NSString stringWithFormat:@"%u", offset], @"offset",
                                kRequestCountString, @"count",  nil];

    [[NNHttpClient sharedClient] getAtPath:kPathCommentList parameters:parameters responseClass:[CommentListModel class] success:^(id<Jsonable> response) {
        if (requestType == RequestTypeAppend) {
            [self.dataModel appendMoreData:response];
        } else {
            self.dataModel = response;
        }
        
        [self updateTableView:requestType];
    } failure:^(ResponseError *error) {
        DLog(@"error:%@", error.message);
        if (self.isVisible) {
            [UIHelper alertWithMessage:error.message];
        }
        [_tableView.pullToRefreshView stopAnimating];
        [_tableView.infiniteScrollingView stopAnimating];
    }];

}

- (void)publishComment:(NSString *)comment withContentId:(NSString *)contentId {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    SessionManager *sessionManager = [SessionManager sharedManager];
    [sessionManager requsetToken:self success:^(NSString *token) {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:token, @"token",
                                    contentId, @"content_id", comment, @"content", nil];
        
        [[NNHttpClient sharedClient] postAtPath:kPathPublishComment parameters:parameters responseClass:nil success:^(id<Jsonable> response) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            _articleInfo.commentNum++;
            [_commentBox.countButton setTitle:[NSNumber numberWithInteger:_articleInfo.commentNum].description forState:UIControlStateNormal];
            _commentBox.text = @"";
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView triggerPullToRefresh];
            });
            
        } failure:^(ResponseError *error) {
            DLog(@"error:%@", error.message);
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (self.isVisible) {
                [UIHelper alertWithMessage:error.message];
            }
        }];
        
    }];
}

#pragma mark - Private methods

- (void)publish:(UIButton *)button {
    NSString *comment = _commentBox.text;
    if (comment.length < 1) {
        [UIHelper alertWithMessage:@"评论不能为空"];
        return;
    }
    
    [self publishComment:_commentBox.text withContentId:_articleInfo.contentId];
}

- (void)back:(UIButton *)button {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.2f];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
    [self.navigationController popViewControllerAnimated:NO];
    [UIView commitAnimations];
}

@end
