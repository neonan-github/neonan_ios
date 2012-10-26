//
//  CommentListControllerViewController.m
//  Neonan
//
//  Created by capricorn on 12-10-22.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "CommentListController.h"
#import "CommentBox.h"
#import "CommentModel.h"
#import "CommentCell.h"

#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f

@interface CommentListController ()
@property (nonatomic, unsafe_unretained) UITableView *tableView;
@property (nonatomic, unsafe_unretained) CommentBox *commentBox;

@property (nonatomic, strong) NSMutableArray *comments;
@end

@implementation CommentListController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    titleLabel.text = @"卡地亚Tortue万年历腕表";
    titleLabel.textAlignment = UITextAlignmentCenter;
    [self.view addSubview:titleLabel];
    
    UITableView *tableView = self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 30, 320, 350)];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:tableView];
    
    CommentBox *commentBox = self.commentBox = [[CommentBox alloc] initWithFrame:CGRectMake(0, 420, 320, 40)];
    [self.view addSubview:commentBox];
    
    self.comments = [[NSMutableArray alloc] initWithCapacity:20];
    for (NSUInteger i = 0; i < 20; i++) {
        CommentModel *comment = [[CommentModel alloc] init];
        [self.comments addObject:comment];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cleanUp
{
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
    self.tableView = nil;
    
    self.commentBox = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self cleanUp];
}

- (void)dealloc
{
    [self cleanUp];
}

#pragma mark - UIViewController life cycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
}

#pragma mark － UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForRowAtIndexPath");
    
    static NSString *cellIdentifier = @"Cell";
    
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[CommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    CommentModel *comment = [self.comments objectAtIndex:indexPath.row];
    cell.commentLabel.font = [UIFont systemFontOfSize:14];
    cell.commentLabel.numberOfLines = comment.expanded ? 0 : 2;
    cell.commentLabel.lineBreakMode = comment.expanded ? UILineBreakModeWordWrap : UILineBreakModeTailTruncation;
    cell.commentLabel.text = [NSString stringWithFormat:@"%u %@", indexPath.row, comment.text];
    
    cell.userNameLabel.font = [UIFont systemFontOfSize:13];
    cell.userNameLabel.text = comment.userName;
    
    cell.timeLabel.font = [UIFont systemFontOfSize:13];
    cell.timeLabel.text = comment.time;
    
    comment.expandable = [UIHelper computeContentLines:cell.commentLabel.text withWidth:[CommentCell getContentWidth:320] andFont:cell.commentLabel.font] > 2;
    cell.arrowView.hidden = !comment.expandable;
    
    return cell;
    
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectRowAtIndexPath:%@", indexPath);
    
    CommentModel *comment = [self.comments objectAtIndex:indexPath.row];
    comment.expanded = !comment.expanded;
    
    if (comment.expandable) {
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionNone animated:YES];
    //    [tableView reloadData];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CommentModel *comment = [self.comments objectAtIndex:indexPath.row];
    UIFont *font = [UIFont systemFontOfSize:14];
    
    NSUInteger lines = [UIHelper computeContentLines:comment.text withWidth:[CommentCell getContentWidth:320] andFont:font];
    CGFloat shrinkedHeight = font.lineHeight * MIN(lines, 2) + [CommentCell getFixedPartHeight];
    
    if (!comment.expanded) {
        return shrinkedHeight;
    }
    
    NSString *text = [NSString stringWithFormat:@"%u %@", indexPath.row, comment.text];
    NSLog(@"text:%@", text);
    
    CGSize constraint = CGSizeMake([CommentCell getContentWidth:320], 20000.0f);
    
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    
    return MAX(size.height + [CommentCell getFixedPartHeight], shrinkedHeight);
}

#pragma mark - Keyboard events handle

//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
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
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
	
	// get a rect for the textView frame
	CGRect containerFrame = self.commentBox.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
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

@end
