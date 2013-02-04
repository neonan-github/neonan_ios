//
//  TopicDetailController.m
//  Neonan
//
//  Created by capricorn on 13-1-31.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "TopicDetailController.h"

#import "TopicDetailModel.h"
#import "NearTopicDetailsModel.h"

#import "DBHelper.h"

#import <UIImageView+WebCache.h>
#import <MBProgressHUD.h>
#import <TTTAttributedLabel.h>

static const CGFloat kFixedPartHeight = 300;

static NSString *const kDBName = @"valuate.db";
static NSString *const kTableName = @"valuation";
static NSString *const kIDKey = @"contentId";
static NSString *const kTypeKey = @"type";

@interface TopicDetailController ()

@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageView;
@property (unsafe_unretained, nonatomic) IBOutlet TTTAttributedLabel *nameLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *praiseButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *criticiseButton;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *contentLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *numSymbolLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *rankLabel;
@property (weak, nonatomic) IBOutlet UIImageView *leftArrowView;
@property (weak, nonatomic) IBOutlet UIImageView *rightArrowView;

@property (nonatomic, strong) TopicDetailModel *dataModel;

@property (nonatomic, strong) DBHelper *dbHelper;

@property (nonatomic, unsafe_unretained) CALayer *cacheLayer;
@property (nonatomic, assign) BOOL isAnimating;

@end

@implementation TopicDetailController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (DBHelper *)dbHelper {
    if (!_dbHelper) {
        _dbHelper = [[DBHelper alloc] initWithDBName:kDBName];
    }
    
    return _dbHelper;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    CustomNavigationBar *customNavigationBar = (CustomNavigationBar *)self.navigationController.navigationBar;
    // Create a custom back button
    UIButton* backButton = [UIHelper createBackButton:customNavigationBar];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    UISwipeGestureRecognizer *swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    [swipeLeftRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipeLeftRecognizer];
    UISwipeGestureRecognizer *swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    [swipeRightRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeRightRecognizer];
    
    self.view.backgroundColor = DarkThemeColor;
    
    _nameLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
}

- (void)cleanUp {
    self.scrollView = nil;
    self.imageView = nil;
    self.praiseButton = nil;
    self.criticiseButton = nil;
    self.contentLabel = nil;
    self.rankLabel = nil;
    self.numSymbolLabel = nil;
    self.leftArrowView = nil;
    self.rightArrowView = nil;
    
    self.dataModel = nil;
    self.cacheLayer = nil;
    self.dbHelper = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self displayChineseName:_chName englishName:@" "];
    [self displayRank:_rank];
    
    if (!_dataModel) {
        [self requestData:_detailId];
    }
}

#pragma mark - Private UI related

- (void)updateData {
    [_imageView setImageWithURL:[NSURL URLWithString:_dataModel.imageUrl] placeholderImage:[UIImage imageNamed:@"img_common_list_place_holder.png"]];
    [self displayChineseName:_chName englishName:_dataModel.enName];
    [self displayContent:_dataModel.description];
    [self displayRank:_rank];
    
    [_praiseButton setTitle:[NSString stringWithFormat:@"%d", _dataModel.upCount] forState:UIControlStateNormal];
    [_criticiseButton setTitle:[NSString stringWithFormat:@"%d", _dataModel.downCount] forState:UIControlStateNormal];
    [self updateValuationState];
}

- (void)displayChineseName:(NSString *)chName englishName:(NSString *)enName {
    enName = !enName ? @" " : enName;
    NSString *text = [NSString stringWithFormat:@"%@ %@", chName, enName];
    _nameLabel.hidden = NO;
    [_nameLabel setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange bigRange = [[mutableAttributedString string] rangeOfString:chName options:NSCaseInsensitiveSearch];
        NSRange smallRange = [[mutableAttributedString string] rangeOfString:enName options:NSCaseInsensitiveSearch];
        
        // Core Text APIs use C functions without a direct bridge to UIFont. See Apple's "Core Text Programming Guide" to learn how to configure string attributes.
        UIFont *bigFont = [UIFont boldSystemFontOfSize:16];
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)bigFont.fontName, bigFont.pointSize, NULL);
        if (font) {
            [mutableAttributedString removeAttribute:(NSString *)kCTFontAttributeName range:bigRange];
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:bigRange];
            CFRelease(font);
        }
        
        UIFont *smallFont = [UIFont systemFontOfSize:11];
        font = CTFontCreateWithName((__bridge CFStringRef)smallFont.fontName, smallFont.pointSize, NULL);
        if (font) {
            [mutableAttributedString removeAttribute:(NSString *)kCTFontAttributeName range:smallRange];
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:smallRange];
            [mutableAttributedString removeAttribute:(NSString *)kCTForegroundColorAttributeName range:smallRange];
            [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)RGBA(255, 255, 255, 0.5).CGColor range:smallRange];
            CFRelease(font);
        }
        
        return mutableAttributedString;
    }];
}

- (void)displayRank:(NSInteger)rank {
    _leftArrowView.alpha = rank >= _maxRank ? 0.3 : 1;
    _rightArrowView.alpha = rank <= 1 ? 0.3 : 1;
    
    NSString *text = [NSString stringWithFormat:@"%d", rank];
    [_rankLabel setText:text];
    [_rankLabel sizeToFit];
    [_rankLabel setCenterX:self.view.center.x];
    
    _numSymbolLabel.x = _rankLabel.x - 8;
}

- (void)displayContent:(NSString *)content {
    _contentLabel.hidden = NO;
    
    CGSize constraint = CGSizeMake(_contentLabel.width, 20000.0f);
    CGSize size = [content sizeWithFont:_contentLabel.font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    _contentLabel.height = size.height;
    _contentLabel.text = content;
    
    UIScrollView *scrollView = self.scrollView;
    scrollView.contentSize = CGSizeMake(CompatibleScreenWidth, kFixedPartHeight + size.height);
}

- (void)updateValuationState {
    NSDictionary *valuation = [self fetchValuation:_detailId];
    ValuationType valuationType = [valuation[@"type"] integerValue];
    
    NSString *normalImageName = valuationType == ValuationTypeUp ? @"icon_praise_highlighted.png" : @"icon_praise_normal.png";
    NSString *highlightedImageName = valuationType == ValuationTypeUp ? @"icon_praise_normal.png" : @"icon_praise_highlighted.png";
    [_praiseButton setImage:[UIImage imageFromFile:normalImageName] forState:UIControlStateNormal];
    [_praiseButton setImage:[UIImage imageFromFile:highlightedImageName] forState:UIControlStateHighlighted];
    
    normalImageName = valuationType == ValuationTypeDown ? @"icon_criticise_highlighted.png" : @"icon_criticise_normal.png";
    highlightedImageName = valuationType == ValuationTypeDown ? @"icon_criticise_normal.png" : @"icon_criticise_highlighted.png";
    [_criticiseButton setImage:[UIImage imageFromFile:normalImageName] forState:UIControlStateNormal];
    [_criticiseButton setImage:[UIImage imageFromFile:highlightedImageName] forState:UIControlStateHighlighted];
}

- (void)clearContents {
    self.dataModel = nil;
    
    _imageView.image = [UIImage imageNamed:@"img_common_list_place_holder.png"];
    
    _nameLabel.hidden = YES;
    [_praiseButton setTitle:@"" forState:UIControlStateNormal];
    [_criticiseButton setTitle:@"" forState:UIControlStateNormal];
    _contentLabel.hidden = YES;
}

- (void)performBounce:(BOOL)left {
    CAAnimation *animation = [UIHelper createBounceAnimation:left ? NNDirectionLeft : NNDirectionRight];
    [CATransaction begin];
    [self.view.layer addAnimation:animation forKey:@"bounceAnimation"];
    [CATransaction commit];
}

#pragma mark - Private Request methods

- (void)requestData:(NSString *)contentId {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSDictionary *parameters = @{@"content_id" : contentId};
    
    [[NNHttpClient sharedClient] getAtPath:@"api/subject/people" parameters:parameters responseClass:[TopicDetailModel class] success:^(id<Jsonable> response) {
        self.dataModel = response;
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self updateData];
    } failure:^(ResponseError *error) {
        NSLog(@"error:%@", error.message);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (self.isVisible) {
            [UIHelper alertWithMessage:error.message];
        }
    }];
}

- (void)requestNearData:(BOOL)next topicId:(NSString *)topicId detailId:(NSString *)detailId {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSDictionary *parameters = @{@"content_id" : detailId, @"subject_id" : topicId, @"direction" : @(next ? 1 : -1)};
    
    [[NNHttpClient sharedClient] getAtPath:@"api/subject/near_people" parameters:parameters responseClass:[NearTopicDetailsModel class] success:^(id<Jsonable> response) {
        self.dataModel = ((NearTopicDetailsModel *) response).items[0];
        self.chName = _dataModel.chName;
        self.rank = _dataModel.ranking;
        self.detailId = _dataModel.contentId;
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self updateData];
    } failure:^(ResponseError *error) {
        NSLog(@"error:%@", error.message);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (self.isVisible) {
            [UIHelper alertWithMessage:error.message];
        }
    }];
}

- (void)requestVoteForContentId:(NSString *)contentId withResult:(NSArray *)voteResult {
    NSDictionary *parameters = @{@"type" : @"subject", @"content_id" : contentId, @"up" : voteResult[0], @"down" : voteResult[1]};
    
    [[NNHttpClient sharedClient] getAtPath:@"haha/api/vote" parameters:parameters responseClass:nil success:^(id<Jsonable> response) {
    } failure:^(ResponseError *error) {
        NSLog(@"error:%@", error.message);
    }];
}

#pragma mark - Private methods

- (NSArray *)computeVoteFromType:(ValuationType)fromType toType:(ValuationType)toType {
    if (fromType != toType) {
        NSInteger up = fromType == ValuationTypeUp ? -1 : (toType == ValuationTypeUp ? 1 : 0);
        NSInteger down = fromType == ValuationTypeDown ? -1 : (toType == ValuationTypeDown ? 1 : 0);
        
        return @[@(up), @(down)];
    }
    
    return @[@0, @(0)];
}

- (void)doValuate:(ValuationType)valuationType {
    NSString *contentId = [_detailId copy];
    if (!contentId) {
        return;
    }
    
    NSDictionary *valuation = [self fetchValuation:contentId];
    ValuationType fromType = [valuation[kTypeKey] integerValue];
    ValuationType toType = fromType !=  valuationType ? valuationType : ValuationTypeNone;
    [self storeValuation:contentId withType:toType];
    
    NSArray *voteResult = [self computeVoteFromType:fromType toType:toType];
    _dataModel.upCount += [voteResult[0] integerValue];
    _dataModel.downCount += [voteResult[1] integerValue];
    [self updateData];
    
    [self requestVoteForContentId:contentId withResult:voteResult];
}

- (NSDictionary *)fetchValuation:(NSString *)contentId {
    FMDatabase *db = self.dbHelper.db;
    if (![db open]) {
        return nil;
    }
    
    FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"select type from valuation where content_id = '%@'",
                                        contentId]];
    NSDictionary *result = nil;
    if ([rs next]) {
        result =  @{kIDKey : contentId, kTypeKey : [rs stringForColumn:@"type"]};
    }
    [rs close];
    [db close];
    
    return result;
}

- (void)storeValuation:(NSString *)contentId withType:(ValuationType)type {
    FMDatabase *db = self.dbHelper.db;
    if (![db open]) {
        return;
    }
    
    [db executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (content_id TEXT PRIMARY KEY NOT NULL, type INTEGER)", kTableName]];
    FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"select * from %@ where content_id = '%@'",
                                        kTableName,
                                        contentId]];
    if ([rs next]) {
        [db executeUpdate:[NSString stringWithFormat:@"update %@ set type = %d where content_id = '%@'", kTableName, type, contentId]];
    } else {
        [db executeUpdate:[NSString stringWithFormat:@"insert into %@ (content_id, type) values('%@', %d)", kTableName, contentId, type]];
    }
    
    [rs close];
    [db close];
}

- (IBAction)praiseUp:(id)sender {
    [self doValuate:ValuationTypeUp];
}

- (IBAction)criticiseDown:(id)sender {
    [self doValuate:ValuationTypeDown];
}

- (void)swipe:(UISwipeGestureRecognizer *)recognizer {
    if (_isAnimating || !_dataModel) {
        return;
    }
    
    BOOL next = recognizer.direction == UISwipeGestureRecognizerDirectionLeft;
    
    if ((_rank >= _maxRank && !next) || (_rank <=1 && next)) {// 到头或尾
        [self performBounce:!next];
        return;
    }

    self.isAnimating = YES;

    CGFloat viewWidth = self.view.frame.size.width;
    CGFloat viewHeight = self.view.frame.size.height;
    
    CALayer *cacheLayer = self.cacheLayer = [CALayer layer];
    UIImage *cacheImage = [UIImage imageFromView:self.view];
    cacheLayer.frame = CGRectMake((next ? -1 : 1) * viewWidth, 0, viewWidth, viewHeight);
    cacheLayer.contents = (id)cacheImage.CGImage;
    [self.view.layer insertSublayer:cacheLayer above:self.view.layer];
    
    [self clearContents];
    [self displayRank:_rank + (next ? -1 :1)];

    [self requestNearData:next topicId:_topicId detailId:_detailId];

    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    //    animation.duration = 5;
    animation.delegate = self;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.fromValue = [NSValue valueWithCGPoint:CGPointMake((next ? 1.5f : -0.5f) * viewWidth, viewHeight / 2)];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(viewWidth / 2, viewHeight / 2)];
    [self.view.layer addAnimation:animation forKey:@"position"];
}

#pragma mark - CAAnimationDelegate methods

- (void)animationDidStart:(CAAnimation *)anim {
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    self.isAnimating = !flag;
    [self.cacheLayer removeFromSuperlayer];
}

@end
