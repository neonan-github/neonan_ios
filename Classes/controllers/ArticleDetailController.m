//
//  ArticleDetailController.m
//  Neonan
//
//  Created by capricorn on 12-10-23.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "ArticleDetailController.h"
#import "SignController.h"
#import "CommentListController.h"
#import "NNNavigationController.h"

#import "CommentBox.h"
#import <DTCoreText.h>

@interface ArticleDetailController ()

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *titleLabel;
@property (unsafe_unretained, nonatomic) IBOutlet DTAttributedTextView *textView;
@property (unsafe_unretained, nonatomic) IBOutlet CommentBox *commentBox;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *shareButton;
//@property (strong, nonatomic) IBOutlet UIButton *commentButton;

@end

@implementation ArticleDetailController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = DarkThemeColor;
    
    CustomNavigationBar *customNavigationBar = (CustomNavigationBar *)self.navigationController.navigationBar;
    // Create a custom back button
    UIButton* backButton = [UIHelper createBackButton:customNavigationBar];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
//    [_commentButton removeFromSuperview];
//    [_commentButton addTarget:self action:@selector(showComments) forControlEvents:UIControlEventTouchUpInside];
//    _commentBox.rightView = _commentButton;
    [_commentBox.countButton addTarget:self action:@selector(showComments) forControlEvents:UIControlEventTouchUpInside];
    [_commentBox.doneButton addTarget:self action:@selector(publish:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [self setTextView:nil];
    [self setCommentBox:nil];
    [self setShareButton:nil];
    [super viewDidUnload];
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

#pragma mark - Keyboard events handle

//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
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
    
//    CGRect tableFrame = self.tableView.frame;
//    tableFrame.size.height = containerFrame.origin.y - tableFrame.origin.y;
    
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
	
	// set views with new info
	self.commentBox.frame = containerFrame;
//    self.tableView.frame = tableFrame;
	
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
    
//    CGRect tableFrame = self.tableView.frame;
//    tableFrame.size.height = containerFrame.origin.y - tableFrame.origin.y;
	
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
	// set views with new info
	self.commentBox.frame = containerFrame;
//    self.tableView.frame = tableFrame;
	
	// commit animations
	[UIView commitAnimations];
}

#pragma mark - Private methods

- (void)publish:(UIButton *)button {
    SignController *controller = [[SignController alloc] init];
    UINavigationController *navController = [[NNNavigationController alloc] initWithRootViewController:controller];
    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.navigationController presentModalViewController:navController animated:YES];
}

- (void)showComments {
    CommentListController *controller = [[CommentListController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
