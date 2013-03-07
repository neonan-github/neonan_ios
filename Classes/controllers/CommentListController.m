//
//  CommentListControllerViewController.m
//  Neonan
//
//  Created by capricorn on 12-10-22.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "CommentListController.h"
#import "NNNavigationController.h"

#import "CommentListModel.h"
#import "ShareHelper.h"

#import "CommentBox.h"
#import "CommentCell.h"

#import "SVPullToRefresh.h"

#import <MBProgressHUD.h>

#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f
#define COMMENT_BOX_ORIGINAL_HEIGHT 40.0f

static const NSUInteger kRequestCount = 20;
static NSString * const kRequestCountString = @"20";

@interface CommentListController () <UITableViewDataSource, UITableViewDelegate,
HPGrowingTextViewDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *titleLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *shareButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *titleLineView;
@property (nonatomic, unsafe_unretained) IBOutlet UITableView *tableView;
@property (nonatomic, unsafe_unretained) IBOutlet CommentBox *commentBox;
//@property (nonatomic, strong) UIButton *commentButton;

//@property (nonatomic, strong) NSMutableArray *comments;
@property (strong, nonatomic) ShareHelper *shareHelper;
@property (nonatomic, strong) CommentListModel *dataModel;
@end

@implementation CommentListController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = DarkThemeColor;
    
    CustomNavigationBar *customNavigationBar = (CustomNavigationBar *)self.navigationController.navigationBar;
    // Create a custom back button
    UIButton* backButton = [UIHelper createBackButton:customNavigationBar];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    [self adjustLayout:_articleInfo.title];
    _titleLabel.text = _articleInfo.title;
    
    [_shareButton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    
    _tableView.backgroundColor = DarkThemeColor;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView addPullToRefreshWithActionHandler:^{
        // refresh data
        // call [tableView.pullToRefreshView stopAnimating] when done
        [self requestForComments:_articleInfo.contentId withRequestType:RequestTypeRefresh];
    }];
    _tableView.pullToRefreshView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    [_tableView addInfiniteScrollingWithActionHandler:^{
        // add data to data source, insert new cells into table view
        [self requestForComments:_articleInfo.contentId withRequestType:RequestTypeAppend];
    }];
    _tableView.infiniteScrollingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    _tableView.showsInfiniteScrolling = NO;
    
//    self.comments = [[NSMutableArray alloc] initWithCapacity:20];
//    for (NSUInteger i = 0; i < 20; i++) {
//        CommentModel *comment = [[CommentModel alloc] init];
//        [self.comments addObject:comment];
//    }

    [_commentBox.countButton setTitle:[NSString stringWithFormat:@"%u", _articleInfo.commentNum] forState:UIControlStateNormal];
    _commentBox.countButton.enabled = NO;
    
    [_commentBox.doneButton addTarget:self action:@selector(publish:) forControlEvents:UIControlEventTouchUpInside]; 
}

- (void)cleanUp {
    self.titleLineView = nil;
    self.titleLabel = nil;
    self.shareButton = nil;
    
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
    self.tableView = nil;
    
    self.commentBox = nil;
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
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_tableView.pullToRefreshView triggerRefresh];
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
    NSLog(@"cellForRowAtIndexPath");
    
    static NSString *cellIdentifier = @"Cell";
    
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[CommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    CommentItem *comment = [_dataModel.items objectAtIndex:indexPath.row];
    cell.commentLabel.numberOfLines = comment.expanded ? 0 : 2;
    cell.commentLabel.lineBreakMode = comment.expanded ? UILineBreakModeWordWrap : UILineBreakModeTailTruncation;
    cell.commentLabel.text = comment.content;
    
    cell.userNameLabel.text = comment.visitor;
    
    cell.timeLabel.text = comment.date;
    
    [cell setVip:(indexPath.row % 2 == 0) andLevel:12];
    
    cell.expanded = comment.expanded;
    comment.expandable = [UIHelper computeContentLines:cell.commentLabel.text withWidth:[CommentCell getContentWidth:320] andFont:cell.commentLabel.font] > 2;
    cell.arrowView.hidden = !comment.expandable;
    
    return cell;
    
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectRowAtIndexPath:%@", indexPath);
    
    CommentItem *comment = [_dataModel.items objectAtIndex:indexPath.row];
    comment.expanded = !comment.expanded;
    
    if (comment.expandable) {
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionNone animated:YES];
    //    [tableView reloadData];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CommentItem *comment = [_dataModel.items objectAtIndex:indexPath.row];
    UIFont *font = [CommentCell getCommentFont];
    
    NSUInteger lines = [UIHelper computeContentLines:comment.content withWidth:[CommentCell getContentWidth:CompatibleScreenWidth] andFont:font];
    CGFloat shrinkedHeight = font.lineHeight * MIN(lines, 2) + [CommentCell getFixedPartHeight];
    
    if (!comment.expanded) {
        return shrinkedHeight;
    }
    
    CGSize constraint = CGSizeMake([CommentCell getContentWidth:CompatibleScreenWidth], 20000.0f);
    
    CGSize size = [comment.content sizeWithFont:font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    
    return MAX(size.height + [CommentCell getFixedPartHeight], shrinkedHeight);
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

- (void)adjustLayout:(NSString *)title {
    CGFloat titleOriginalHeight = _titleLabel.frame.size.height;
    CGFloat titleAdjustedHeight = [UIHelper computeHeightForLabel:_titleLabel withText:title];
    CGFloat delta = titleAdjustedHeight - titleOriginalHeight;
    
    CGRect frame = _titleLabel.frame;
    frame.size.height = titleAdjustedHeight;
    _titleLabel.frame = frame;
    
    frame = _titleLineView.frame;
    frame.origin.y += delta;
    _titleLineView.frame = frame;
    
    frame = _tableView.frame;
    frame.origin.y += delta;
    frame.size.height -= delta;
    _tableView.frame = frame;
}

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
        NSLog(@"error:%@", error.message);
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
            
            [_tableView.pullToRefreshView triggerRefresh];
        } failure:^(ResponseError *error) {
            NSLog(@"error:%@", error.message);
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (self.isVisible) {
                [UIHelper alertWithMessage:error.message];
            }
        }];
        
    }];
}

#pragma mark - Private methods

- (void)share {
    if (!_dataModel) {
        return;
    }
    
    if (!self.shareHelper) {
        self.shareHelper = [[ShareHelper alloc] initWithRootViewController:self];
    }
    
    _shareHelper.shareText = _articleInfo.title;
    _shareHelper.shareUrl = _articleInfo.shareUrl;
    [_shareHelper showShareView];
}

- (void)publish:(UIButton *)button {
    NSString *comment = _commentBox.text;
    if (comment.length < 1) {
        [UIHelper alertWithMessage:@"评论不能为空"];
        return;
    }
    
    [self publishComment:_commentBox.text withContentId:_articleInfo.contentId];
}

@end
