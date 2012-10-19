//
//  CommentListMediator.m
//  Neonan
//
//  Created by capricorn on 12-10-19.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "CommentListMediator.h"
#import "CommentModel.h"
#import "CommentBox.h"
#import <HPGrowingTextView.h>
#import "CommentCell.h"

#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f

@interface CommentListMediator ()
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) CommentBox *commentBox;

@property (nonatomic, retain) NSMutableArray *comments;
@end

@implementation CommentListMediator
@synthesize tableView = _tableView;

- (void)viewDidLoad
{
    UILabel *navBar = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)] autorelease];
    navBar.text = @"自定义导航栏";
    navBar.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
    navBar.textAlignment = NSTextAlignmentCenter;
    navBar.userInteractionEnabled = YES;
    [self addSubview:navBar];
    
    UIButton *back = [[[UIButton alloc] initWithFrame:CGRectMake(10, 5, 60, 30)] autorelease];
    back.layer.cornerRadius = 10;
    [back setBackgroundColor:[UIColor grayColor]];
    [back setTitle:@"返回" forState:UIControlStateNormal];
    [back setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [back setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:back];
    
    UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 40, 320, 30)] autorelease];
    titleLabel.text = @"卡地亚Tortue万年历腕表";
    titleLabel.textAlignment = UITextAlignmentCenter;
    [self addSubview:titleLabel];
    
    UITableView *tableView = self.tableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 70, 320, 350)] autorelease];
    tableView.dataSource = self;
    tableView.delegate = self;
    [self addSubview:tableView];
    
    CommentBox *commentBox = self.commentBox = [[[CommentBox alloc] initWithFrame:CGRectMake(0, 460 - 40, 320, 40)] autorelease];
    [self addSubview:commentBox];
    
    self.comments = [[[NSMutableArray alloc] initWithCapacity:20] autorelease];
    for (NSUInteger i = 0; i < 20; i++) {
        CommentModel *comment = [[[CommentModel alloc] init] autorelease];
        [self.comments addObject:comment];
    }
}

- (void)dealloc
{
    self.comments = nil;
    self.tableView = nil;
    self.commentBox = nil;
    [super dealloc];
}

- (void)back
{
    [self popMediatorWithAnimation:From_Left];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification 
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        cell = [[[CommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    CommentModel *comment = [self.comments objectAtIndex:indexPath.row];
    cell.commentLabel.font = [UIFont systemFontOfSize:14];
    cell.commentLabel.textColor = [UIColor blackColor];
    cell.commentLabel.numberOfLines = comment.expanded ? 0 : 2;
    cell.commentLabel.lineBreakMode = comment.expanded ? UILineBreakModeWordWrap : UILineBreakModeTailTruncation;
    cell.commentLabel.text = [NSString stringWithFormat:@"%u %@", indexPath.row, comment.text];
    
    return cell;
    
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectRowAtIndexPath:%@", indexPath);
    
    CommentModel *comment = [self.comments objectAtIndex:indexPath.row];
    comment.expanded = !comment.expanded;
    
	[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	[tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionNone animated:YES];
//    [tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CommentModel *comment = [self.comments objectAtIndex:indexPath.row];
    if (!comment.expanded) {
        NSLog(@"xxx heightForRow:%u %f", indexPath.row, 44.0);
        return 80;
    }
    
    NSString *text = [NSString stringWithFormat:@"%u %@", indexPath.row, comment.text];;
    
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
    
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    
    CGFloat height = MAX(size.height, 44.0f);
    
    NSLog(@"yyy heightForRow:%u %f", indexPath.row, height + (4 * 2));
    return height + (4 * 2);
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
    keyboardBounds = [self convertRect:keyboardBounds toView:nil];
    
	// get a rect for the textView frame
	CGRect containerFrame = self.commentBox.frame;
    containerFrame.origin.y = self.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    
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
    containerFrame.origin.y = self.bounds.size.height - containerFrame.size.height;
    
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
