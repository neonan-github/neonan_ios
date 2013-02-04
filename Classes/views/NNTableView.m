//
//  NNTableView.m
//  Neonan
//
//  Created by capricorn on 13-1-31.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "NNTableView.h"

@interface NNTableView ()

@property (nonatomic, assign) BOOL loading;
@property (nonatomic, copy) void (^loadedBock)();

@end

@implementation NNTableView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self addObserver:self forKeyPath:@"loading" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)reloadData {
    // http://stackoverflow.com/questions/1483581/get-notified-when-uitableview-has-finished-asking-for-data
    self.loading = YES;
    
    [super reloadData];
    
    self.loading = NO;
    if (self.loadedBock) {
        _loadedBock();
        self.loadedBock = nil;
    }
}

- (void)doUntilLoaded:(void (^)())block {
    if (!self.loading) {
        block();
        return;
    }
    
    self.loadedBock = block;
}

@end
