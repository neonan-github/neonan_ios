//
//  GalleryDetailController.h
//  Neonan
//
//  Created by capricorn on 12-10-22.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideShowView.h"
#import "FoldableTextBox.h"

@interface GalleryDetailViewController : NNViewController

@property (assign, nonatomic) SortType sortType;
@property (copy, nonatomic) NSString *channel;
@property (copy, nonatomic) NSString *contentType;
@property (copy, nonatomic) NSString *contentId;
@property (copy, nonatomic) NSString *contentTitle;
@property (assign, nonatomic) BOOL voted;

//@property (nonatomic, assign) NSInteger currentIndex;
//@property (nonatomic, assign) NSInteger maxIndex;

@end
