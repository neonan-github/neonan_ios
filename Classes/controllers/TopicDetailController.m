//
//  TopicDetailController.m
//  Neonan
//
//  Created by capricorn on 13-1-31.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "TopicDetailController.h"

#import "DBHelper.h"

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

@property (nonatomic, strong) DBHelper *dbHelper;

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
    
    self.title = @"TOP 99 女人";
    
    CustomNavigationBar *customNavigationBar = (CustomNavigationBar *)self.navigationController.navigationBar;
    // Create a custom back button
    UIButton* backButton = [UIHelper createBackButton:customNavigationBar];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    _nameLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
    [self displayChineseName:@"大S" englishName:@"Barbie Hsu"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setImageView:nil];
    [self setNameLabel:nil];
    [self setPraiseButton:nil];
    [self setCriticiseButton:nil];
    [self setContentLabel:nil];
    [self setRankLabel:nil];
    [self setNumSymbolLabel:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self displayContent:@"台湾著名艺人。因出演《流星花园》中杉菜一角红遍全亚洲，并入围金钟奖最佳女主角奖。其后又在多部热门偶像剧和电影中担当女主角。 大S因比较善于美容而取代伊能静而成为台湾美容大王，成功成为多家时尚品的形象代言人，而与汪小菲的感情问题也是大众所观注的焦点话题，从而人气一直居高不下。"];
    [self displayRank:15];
}

#pragma mark - Private UI related

- (void)displayChineseName:(NSString *)chName englishName:(NSString *)enName {
    NSString *text = [NSString stringWithFormat:@"%@ %@", chName, enName];
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
    NSString *text = [NSString stringWithFormat:@"%d", rank];
    [_rankLabel setText:text];
    [_rankLabel sizeToFit];
    [_rankLabel setCenterX:self.view.center.x];
    
    _numSymbolLabel.x = _rankLabel.x - 8;
}

- (void)displayContent:(NSString *)content {
    CGSize constraint = CGSizeMake(_contentLabel.width, 20000.0f);
    CGSize size = [content sizeWithFont:_contentLabel.font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    _contentLabel.height = size.height;
    _contentLabel.text = content;
    
    UIScrollView *scrollView = self.scrollView;
    scrollView.contentSize = CGSizeMake(CompatibleScreenWidth, kFixedPartHeight + size.height);
}

- (void)updateValuationState:(NSString *)contentId {
    NSDictionary *valuation = [self fetchValuation:contentId];
    ValuationType valuationType = [valuation[@"type"] integerValue];
    
    NSString *normalImageName = valuationType == ValuationTypeUp ? @"icon_praise.png" : @"icon_praise.png";
    NSString *highlightedImageName = valuationType == ValuationTypeUp ? @"icon_praise.png" : @"icon_praise.png";
    [_praiseButton setImage:[UIImage imageFromFile:normalImageName] forState:UIControlStateNormal];
    [_praiseButton setImage:[UIImage imageFromFile:highlightedImageName] forState:UIControlStateHighlighted];
    
    normalImageName = valuationType == ValuationTypeDown ? @"icon_criticise.png" : @"icon_criticise.png";
    highlightedImageName = valuationType == ValuationTypeDown ? @"icon_criticise.png" : @"icon_criticise.png";
    [_criticiseButton setImage:[UIImage imageFromFile:normalImageName] forState:UIControlStateNormal];
    [_criticiseButton setImage:[UIImage imageFromFile:highlightedImageName] forState:UIControlStateHighlighted];
}

#pragma mark - Private Request methods

- (void)requestVoteForContentId:(NSString *)contentId withResult:(NSArray *)voteResult {
    NSDictionary *parameters = @{@"type" : @"haha", @"content_id" : contentId, @"up" : voteResult[0], @"down" : voteResult[1]};
    
    [[NNHttpClient sharedClient] getAtPath:@"vote" parameters:parameters responseClass:nil success:^(id<Jsonable> response) {
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
    NSString *contentId = @"1";//[self getCurrentId];
    if (!contentId) {
        return;
    }
    
    NSDictionary *valuation = [self fetchValuation:contentId];
    ValuationType fromType = [valuation[kTypeKey] integerValue];
    ValuationType toType = fromType !=  valuationType ? valuationType : ValuationTypeNone;
    [self storeValuation:contentId withType:toType];
    
    NSArray *voteResult = [self computeVoteFromType:fromType toType:toType];
//    _dataModel.upCount += [voteResult[0] integerValue];
//    _dataModel.downCount += [voteResult[1] integerValue];
//    [self updateData:_dataModel];
    [self updateValuationState:contentId];
    
    [self requestVoteForContentId:contentId withResult:voteResult];
}

- (NSDictionary *)fetchValuation:(NSString *)contentId {
    FMDatabase *db = self.dbHelper.db;
    if (![db open]) {
        return nil;
    }
    
    FMResultSet *rs = [db executeQueryWithFormat:@"select type from valuation where content_id = '%@'", contentId];
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
    
    [db executeUpdateWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (content_id TEXT PRIMARY KEY, type INTEGER)", kTableName];
    FMResultSet *rs = [db executeQueryWithFormat:@"select * from %@ where content_id = '%@'", kTableName, contentId];
    if ([rs next]) {
        [db executeUpdateWithFormat:@"update %@ set type = %d where content_id = '%@'", kTableName, type, contentId];
    } else {
        [db executeUpdateWithFormat:@"insert into %@ (content_id, type) values('%@', %d)", contentId, type];
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


@end
