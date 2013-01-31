//
//  NNTableView.h
//  Neonan
//
//  Created by capricorn on 13-1-31.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NNTableView : UITableView

- (void)doUntilLoaded:(void (^)())block;

@end
