//
//  InfoEditController.m
//  Neonan
//
//  Created by capricorn on 13-3-8.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "InfoEditController.h"

#import "NSData+MKBase64.h"

#import <SVProgressHUD.h>
#import <UIImageView+WebCache.h>
#import <NYXImagesKit.h>

@interface InfoEditController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate,
UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIView *avatarBlockView;
@property (weak, nonatomic) IBOutlet UIView *nameBlockView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UITextField *nameField;

@end

@implementation InfoEditController

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
    
    self.title = @"编辑资料";
    
    UIButton *navLeftButton = [UIHelper createLeftBarButton:@"icon_close_normal.png"];
    [navLeftButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navLeftButton];
    
    UIButton *navRightButton = [UIHelper createRightBarButton:@"icon_done_normal.png"];
    [navRightButton addTarget:self action:@selector(commit) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navRightButton];
    
    self.view.backgroundColor = DarkThemeColor;
    
    _avatarBlockView.layer.cornerRadius = 8;
    _nameBlockView.layer.cornerRadius = 8;
    
    _avatarView.image = _avatarImage ?:[UIImage imageNamed:@"img_default_avatar.jpg"];
    _avatarView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImagePickerSelector)];
    [_avatarView addGestureRecognizer:tapRecognizer];
    
    _nameField.text = _nickName;
}

- (void)cleanUp {
    self.avatarBlockView = nil;
    self.nameBlockView = nil;
    self.avatarView = nil;
    self.nameField = nil;
}

#pragma mark - UIImagePickerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    _avatarView.image = image;
    
    [picker dismissModalViewControllerAnimated:YES];
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex >= actionSheet.numberOfButtons - 1) {
        return;
    }
    
    UIImagePickerController *imgPickerController = [[UIImagePickerController alloc] init];
    imgPickerController.sourceType = buttonIndex ? UIImagePickerControllerSourceTypePhotoLibrary : UIImagePickerControllerSourceTypeCamera;
    imgPickerController.delegate = self;
    imgPickerController.allowsEditing = YES;
    
    [self presentModalViewController:imgPickerController animated:YES];
}


#pragma mark - Private Request related

- (void)updateUserInfo {
    [SVProgressHUD showWithStatus:@"正在更新信息"];
    [[SessionManager sharedManager] requsetToken:self success:^(NSString *token) {
        NSMutableDictionary *parameters = [@{@"token" : token, @"screen_name" : _nameField.text} mutableCopy];
        
        if (_avatarView.image) {
            [parameters setObject:[self imageToBase64String:[self adjustAvatarImage:_avatarView.image]]
                           forKey:@"avatar"];
        }
        
        [[NNHttpClient sharedClient] postAtPath:kPathUpdateUserInfo
                                     parameters:parameters
                                  responseClass:nil
                                        success:^(id<Jsonable> response) {
                                            if (_infoChangedBlock) {
                                                _infoChangedBlock(_avatarView.image, _nameField.text);
                                            }
                                            
                                            [SVProgressHUD showSuccessWithStatus:@"更新成功"];
                                            [self close];
                                        }
                                        failure:^(ResponseError *error) {
                                            DLog(@"error:%@", error.message);
                                            if (error.errorCode == ERROR_UNPREDEFINED) {
                                                [UIHelper alertWithMessage:error.message];
                                            } else {
                                                [SVProgressHUD showErrorWithStatus:@"更新失败"];
                                            }
                                        }];
    }];
}


#pragma mark - Private methods

- (UIImage *)adjustAvatarImage:(UIImage *)image {
    CGFloat imgWidth = image.size.width;
    CGFloat imgHeight = image.size.height;
    imgWidth = imgHeight = MIN(imgWidth, imgHeight);//正方形
    image = [image cropToSize:CGSizeMake(imgWidth, imgHeight)];
    
    if (imgWidth > 150) {
        return [image scaleToFitSize:CGSizeMake(150, 150)];
    }
    
    return image;
}

- (NSString *)imageToBase64String:(UIImage *)image {
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    return [imageData base64EncodedString];
}

- (void)showImagePickerSelector {
    UIActionSheet *actionSheet=[[UIActionSheet alloc] initWithTitle:@"修改头像"
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    
    [actionSheet addButtonWithTitle:@"拍照上传"];
    [actionSheet addButtonWithTitle:@"从相册上传"];
    [actionSheet addButtonWithTitle:@"取消"];
    [actionSheet setCancelButtonIndex:actionSheet.numberOfButtons-1];
    [actionSheet showInView:self.view];
}

- (void)commit {
    [self updateUserInfo];
}

- (void)close {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.8f];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view.window cache:NO];
    [self dismissModalViewControllerAnimated:NO];
    [UIView commitAnimations];
}

@end
