//
//  ViewController.m
//  HackerNews
//
//  Created by Benjamin Gordon on 5/1/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "TFHpple.h"

#import <UIScrollView+SVPullToRefresh.h>
#import <UIScrollView+SVInfiniteScrolling.h>
#import "CrossFadeImageView.h"
#import "EBGPhotoManager.h"

@interface ViewController () {
    // Home Page UI
    __weak IBOutlet UIView *headerContainer;
    __weak IBOutlet UITableView *frontPageTable;
    __weak IBOutlet UIImageView *underHeaderTriangle;
    __weak IBOutlet TriangleView *headerTriangle;
    __weak IBOutlet UIActivityIndicatorView *loadingIndicator;
    UIRefreshControl *frontPageRefresher;
    __weak IBOutlet UIButton *submitLinkButton;
    __strong IBOutlet UIImageView *backgroudImageView;

    // Comments Page UI
    IBOutlet UIView *commentsView;
    __weak IBOutlet UIView *commentsHeader;
    __weak IBOutlet UITableView *commentsTable;
    __weak IBOutlet UILabel *commentPostTitleLabel;
    UIRefreshControl *commentsRefresher;
    __weak IBOutlet UILabel *postTitleLabel;

    // Link Page UI
    __weak IBOutlet UIView *linkHeader;
    __weak IBOutlet UIWebView *linkWebView;
    IBOutlet UIView *linkView;

    __weak IBOutlet UIActivityIndicatorView *linkViewLoadingIndicator;
    // External Link View
    __weak IBOutlet UIWebView *externalLinkWebView;
    IBOutlet UIView *externalLinkView;
    __weak IBOutlet UIView *externalLinkHeader;
    __weak IBOutlet UIActivityIndicatorView *externalActivityIndicator;
    
    
    IBOutlet UIView *bgimageview;
    IBOutlet CrossFadeImageView *bgImageFull;
    IBOutlet CrossFadeImageView *bgImageFullBlurred;
    IBOutlet UIView *blackWashView;
    
    IBOutlet UIButton *sidebarButton;
    // Webservice
    Webservice *HNService;
    NSInteger lastContentOffset;
    // Data
    NSMutableArray *homePagePosts;
    NSMutableDictionary *homePagePostsByFilterID;
    NSMutableDictionary *homePageIDs;
    NSArray *organizedCommentsArray;
    NSMutableArray *openFrontPageCells;
    Post *currentPost;
    float frontPageLastLocation;
    float commentsLastLocation;
    int scrollDirection;
    NSString *filterString;
    NSString *subPageIndex;
    int address;
    EBGPhotoManager* bgPhotoMgr;
    BOOL photoAnimotionStarted;
}

// Change Theme
- (void)colorUI;
- (IBAction)toggleSideNav:(id)sender;
- (IBAction)toggleRightNav:(id)sender;

- (IBAction)didClickCommentsFromLinkView:(id)sender;
- (IBAction)hideCommentsAndLinkView:(id)sender;
- (IBAction)didClickLinkViewFromComments:(id)sender;
- (IBAction)didClickBackToComments:(id)sender;
@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil filterType:(FilterType)type
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.filterType = type;
        switch (type) {
            case FilterTypeDiscuss:
                filterString = @"7";
                break;
            case FilterTypeNewUs:
                filterString = @"8";
                break;
            case FilterTypeFlag:
                filterString = @"16";
                break;
            case FilterTypeNovel:
                filterString = @"20";
                break;
            case FilterTypeAsiaNo:
                filterString = @"2";
                break;
            case FilterTypeAsiaYes:
                filterString = @"15";
                break;
            case FilterTypeAmerica:
                filterString = @"4";
                break;
            case FilterTypeComic:
                filterString = @"5";
                break;
            case FilterTypeHttpDownload:
                filterString = @"21";
                break;
            default:
                filterString = @"7";
                self.filterType = 0;
                break;
        }
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil filterType:(FilterType)type address:(AddressType)addr
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.addressType = addr;
        switch (addr) {
            case AddressType1:
                address = 1;
                break;
            case AddressType2:
                address = 2;
                break;
            case AddressType3:
                address = 3;
                break;
            case AddressType4:
                address = 4;
                break;
            case AddressType5:
                address = 5;
                break;
            case AddressType6:
                address = 6;
                break;
            case AddressTypeDefault:
                address = 7;
                break;
            default:
                address = 0;
                break;
        }
    }
    if (self) {
        self.filterType = type;
        switch (type) {
            case FilterTypeDiscuss:
                filterString = @"7";
                break;
            case FilterTypeNewUs:
                filterString = @"8";
                break;
            case FilterTypeFlag:
                filterString = @"16";
                break;
            case FilterTypeNovel:
                filterString = @"20";
                break;
            case FilterTypeAsiaNo:
                filterString = @"2";
                break;
            case FilterTypeAsiaYes:
                filterString = @"15";
                break;
            case FilterTypeAmerica:
                filterString = @"4";
                break;
            case FilterTypeComic:
                filterString = @"5";
                break;
            case FilterTypeHttpDownload:
                filterString = @"21";
                break;
            default:
                filterString = @"7";
                self.filterType = 0;
                break;
        }
    }

    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Build NavBar
//    [Helpers buildNavBarForController:self.navigationController];
    self.navigationController.navigationBarHidden = YES;
//    self.navigationController.navigationBar.translucent = YES;
	
    // Set Up Data
    homePagePosts = [@[] mutableCopy];
    homePageIDs = [[NSMutableDictionary alloc]init];
    homePagePostsByFilterID =[[NSMutableDictionary alloc]init];
    organizedCommentsArray = @[];
    openFrontPageCells = [@[] mutableCopy];
    frontPageLastLocation = 0;
    commentsLastLocation = 0;
    HNService = [[Webservice alloc] init];
    HNService.delegate = self;
    
    subPageIndex = @"0";
    // Run methods
    [self loadHomepage];
    [self buildUI];
    [self colorUI];
    //[self setScrollViewToScrollToTop:frontPageTable];

    // Set Up NotificationCenter
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeTheme) name:@"DidChangeTheme" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoginOrOut) name:@"DidLoginOrOut" object:nil];
    
    // Listen for photo animotion complete notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(crossDissolvePhotos)
                                                 name:EPHOTO_ANIMOTION_END_NOTIFICATION
                                               object:nil];
    
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
//        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    // Add Gesture Recognizers
    /*
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressFrontPageCell:)];
    longPress.minimumPressDuration = 0.7;
    longPress.delegate = self;
    [frontPageTable addGestureRecognizer:longPress];
    */
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentCellTapGesture:)];
    tapGesture.delegate = self;
    [commentsTable addGestureRecognizer:tapGesture];
   
    UnpreventableUILongPressGestureRecognizer *longPressRecognizer = [[UnpreventableUILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressRecognizer.allowableMovement = 20;
    longPressRecognizer.minimumPressDuration = 1.0f;
    [linkWebView addGestureRecognizer:longPressRecognizer];
    
    
    //add background image
    
    bgPhotoMgr = [EBGPhotoManager sharedManager];
    [self initBackgroundImageView];
    
    __strong ViewController *Self = self;
    
    [frontPageTable addPullToRefreshWithActionHandler:^{
        [Self refreshHomepage];
    }];
    
    // setup infinite scrolling
    [frontPageTable addInfiniteScrollingWithActionHandler:^{
        [Self loadMoreItems];
    }];
    frontPageTable.infiniteScrollingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    
}


-(void)initBackgroundImageView{
    
    [bgImageFull setImage:[UIImage imageNamed:@"background.jpg"] animate:NO];
    [bgImageFullBlurred setImage:[UIImage imageNamed:@"background.jpg"] animate:NO];
    
    bgImageFullBlurred.alpha = 0.0;
    
    CGSize viewSize = [[UIScreen mainScreen] bounds].size;
    
    bgimageview.frame = CGRectMake(-1.0 * 200, -1.0 * 150,
                                        viewSize.width + 200 , viewSize.height + 150);
    
    [[NSNotificationCenter defaultCenter]postNotificationName:EPHOTO_ANIMOTION_END_NOTIFICATION object:nil];

}

- (void) crossDissolvePhotos{
    
    __weak ViewController* safeSelf = self;
    [[EBGPhotoManager sharedManager] randomStockPhoto:^(NSDictionary * photos) {
        
        [bgImageFull setImage:[photos objectForKey:@"original"] animate:YES];
        [bgImageFullBlurred setImage:[photos objectForKey:@"blurred"] animate:YES];
        
        [NSTimer scheduledTimerWithTimeInterval:1.5 target:safeSelf selector:@selector(addMovingEffectOnBackgroudImages) userInfo:nil repeats:NO];
    }];
}



-(void)addMovingEffectOnBackgroudImages{
    
    
    if(photoAnimotionStarted == YES)return;
    
    NSLog(@"debug: start animotion");
    
    CGSize viewSize = [[UIScreen mainScreen] bounds].size;
    
    CGFloat x = (CGFloat) (arc4random() % (int)200);
    CGFloat y = (CGFloat) (arc4random() % (int)150);
    
    float randx = arc4random() % 2 >0? x/2.0f:x/-2.0f;
    float randy = arc4random() % 2 >0? y/2.0f:y/-2.0f;
    
    CGPoint squarePostion = CGPointMake(viewSize.width/2.0f + randx, viewSize.height/2.0f + randy);
    
    CGFloat dx = squarePostion.x - bgimageview.center.x;
    CGFloat dy = squarePostion.y - bgimageview.center.y;
    CGFloat dist = sqrt(dx*dx + dy*dy );
    
    photoAnimotionStarted = YES;

    [UIView animateWithDuration: 15.0f*dist/100.0 animations: ^{
        
        [bgimageview setCenter:squarePostion];
        
    }completion:^(BOOL finished) {
        photoAnimotionStarted = NO;
        [[NSNotificationCenter defaultCenter]postNotificationName:EPHOTO_ANIMOTION_END_NOTIFICATION object:nil];
    }];
    
}


// set blur of bg image, from 0 (no blur) to 1 (max)
- (void)setBackgroundImageBlur:(CGFloat)blurAmount
{
    bgImageFullBlurred.alpha = blurAmount;
    
    // fade in black wash
    blackWashView.alpha = blurAmount / 3.0;

}


// horizontal parallax
- (void)setHorizParallaxPix:(CGFloat)pix
{
    CGRect frame = CGRectMake(-pix*0.35,
                              bgImageFull.frame.origin.y,
                              bgimageview.frame.size.width,
                              bgimageview.frame.size.height);
    bgImageFull.frame = frame;
    bgImageFullBlurred.frame = frame;
}


//#pragma mark : scrollview deleteage method

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    //    [self setVerticalParallaxPix:scrollView.contentOffset.y];
    if (scrollView == frontPageTable) {
        CGFloat blurYOffDist =  self.view.frame.size.height - 200;
        CGFloat blurAmount = 1.0 + (scrollView.contentOffset.y - blurYOffDist)/blurYOffDist;
        float percent = MAX(0.0, MIN(blurAmount, 1.0));
    
        [self setBackgroundImageBlur:percent];
    }
    
}
//
- (void)setVerticalParallaxPix:(CGFloat)pix
{
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        // ignore in landscape mode - scroll view not visible
        return;
    }
    // move background image for parallax effect, capping out at specified YOFF
    // NOTE: parallax is handled within the background images themselves as the offset for the container
    // is used for tilt effect offsets
    CGFloat bgYOff = -1.0 * MIN(pix, 400.0)/8.0;
    //NSLog(@"setplx pix is %f, bgyoff is %f", pix, bgYOff);
    CGRect frame = CGRectMake(0, bgYOff,
                              bgimageview.frame.size.width,
                              bgimageview.frame.size.height);
    bgImageFull.frame = frame;
    bgImageFullBlurred.frame = frame;
}


-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [self setSizes];
    NSLog(@"%@", NSStringFromCGRect(frontPageTable.frame));
}


#pragma mark - Memory
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UI
-(void)buildUI {
    // Add Refresh Controls
//    frontPageRefresher = [[UIRefreshControl alloc] init];
//    [frontPageRefresher addTarget:self action:@selector(loadHomepage) forControlEvents:UIControlEventValueChanged];
//    frontPageRefresher.tintColor = [UIColor blackColor];
//    frontPageRefresher.alpha = 0.65;
//    [frontPageTable addSubview:frontPageRefresher];
    
//    commentsRefresher = [[UIRefreshControl alloc] init];
//    [commentsRefresher addTarget:self action:@selector(reloadComments) forControlEvents:UIControlEventValueChanged];
//    commentsRefresher.tintColor = [UIColor blackColor];
//    commentsRefresher.alpha = 0.65;
//    [commentsTable addSubview:commentsRefresher];
    
    commentsHeader.backgroundColor = kOrangeColor;
    linkHeader.backgroundColor = kOrangeColor;
    externalLinkHeader.backgroundColor = kOrangeColor;
    
    // Add Shadows
    NSArray *sArray = @[commentsHeader, headerContainer, linkHeader];
    for (UIView *view in sArray) {
        [Helpers makeShadowForView:view withRadius:0];
    }
}

-(void)colorUI {
    // Set Colors for all objects based on Theme
    self.view.backgroundColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"CellBG"];
    frontPageTable.backgroundColor = [UIColor colorWithRed:0/255.0f green:57/255.0f blue:88/255.0f alpha:1];
    frontPageTable.backgroundColor = [UIColor clearColor];
    frontPageTable.tintColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"MainFont"];
    
    frontPageTable.separatorColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"Separator"];
    commentsTable.backgroundColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"CellBG"];
    underHeaderTriangle.backgroundColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"TableTriangle"];
    headerTriangle.color = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"TableTriangle"];
    [headerTriangle drawTriangleAtXPosition:self.view.frame.size.width/2];
    
    // Redraw View
    [self.view setNeedsDisplay];
}

-(void)setSizes {

}

-(void)didChangeTheme {
    // Set alphas to 0 for tables
    // Color the UI
    // Reload tables, and set their alphas to 1
    
    frontPageTable.alpha = 0;
    commentsTable.alpha = 0;
    [UIView animateWithDuration:0.2 animations:^{
        [self colorUI];
    } completion:^(BOOL fin){
        [frontPageTable reloadData];
        [commentsTable reloadData];
        [UIView animateWithDuration:0.2 animations:^{
            frontPageTable.alpha = 1;
            commentsTable.alpha = 1;
        }];
    }];
}


#pragma mark - Toggle Nav
- (IBAction)toggleSideNav:(id)sender {
    [self.viewDeckController toggleLeftView];
}

-(IBAction)toggleRightNav:(id)sender {
    [self.viewDeckController toggleRightView];
}


#pragma mark - Did Login
-(void)didLoginOrOut {
    // Show paper airplane icon to open submit link
    // in right drawer. I might move this to the
    // left drawer instead.
    if ([HNSingleton sharedHNSingleton].User) {
        loadingIndicator.frame = kLoadingRectSubmit;
        submitLinkButton.alpha = 1;
    }
    else {
        loadingIndicator.frame = kLoadingRectNoSubmit;
        submitLinkButton.alpha = 0;
    }
}


#pragma mark - Load HomePage
-(void)loadHomepage {
    

    
    __block UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] init];
//    [Helpers navigationController:self.navigationController addActivityIndicator:&indicator];
    [loadingIndicator startAnimating];
    [HNService getHomepageWithFilter:filterString withAddressNO: address WithSubPageIndex:[subPageIndex intValue] success:^(NSArray *posts) {

        NSMutableArray *append = [[NSMutableArray alloc]init];
        for (Post *one in posts) {
            [append addObject:one];
        }
        
        [homePagePosts addObjectsFromArray:append];
        
        [frontPageTable reloadData];
        [frontPageTable.infiniteScrollingView stopAnimating];
        [frontPageTable.pullToRefreshView stopAnimating];
        [self endRefreshing:frontPageRefresher];
        [loadingIndicator stopAnimating];

        [HNService unlockFNIDLoading];
    } failure:^{
        
        [FailedLoadingView launchFailedLoadingInView:self.view];
        [frontPageTable.infiniteScrollingView stopAnimating];
        [frontPageTable.pullToRefreshView stopAnimating];
        
        if ([subPageIndex intValue]>0) {
            subPageIndex = [NSString stringWithFormat:@"%d",[subPageIndex intValue]-1];
        }

        [self endRefreshing:frontPageRefresher];

        [loadingIndicator stopAnimating];
    }];
}
- (void)loadMoreItems{
    
    if (!subPageIndex) {
        subPageIndex = @"0";
    }
    subPageIndex = [NSString stringWithFormat:@"%d",[subPageIndex intValue]+1];
    [frontPageTable.infiniteScrollingView startAnimating];
    [self loadHomepage];
    
}

- (void)refreshHomepage{
    
    [homePagePosts removeAllObjects];
    [self loadHomepage];
}

#pragma mark - Load Comments
-(void)loadCommentsForPost:(Post *)post {
    __block UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] init];
    [Helpers navigationController:self.navigationController addActivityIndicator:&indicator];
    [HNService getCommentsForPost:post success:^(NSArray *comments){
        currentPost = post;
        organizedCommentsArray = comments;
        [commentsTable reloadData];
        [commentsTable setContentOffset:CGPointZero animated:YES];
        [self launchCommentsView];
        [self endRefreshing:commentsRefresher];
        indicator.alpha = 0;
        [indicator removeFromSuperview];
    } failure:^{
        [FailedLoadingView launchFailedLoadingInView:self.view];
        [self endRefreshing:commentsRefresher];
        indicator.alpha = 0;
        [indicator removeFromSuperview];
    }];
    
    // Start Loading Indicator
    loadingIndicator.alpha = 1;
    [loadingIndicator startAnimating];
}

-(void)reloadComments {
    __block UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] init];
    [Helpers navigationController:self.navigationController addActivityIndicator:&indicator];
    [HNService getCommentsForPost:currentPost success:^(NSArray *comments){
        organizedCommentsArray = comments;
        [commentsTable reloadData];
        [self endRefreshing:commentsRefresher];
        indicator.alpha = 0;
        [indicator removeFromSuperview];
        [commentsTable setContentOffset:CGPointZero animated:YES];
    } failure:^{
        [FailedLoadingView launchFailedLoadingInView:self.view];
        [self endRefreshing:commentsRefresher];
        indicator.alpha = 0;
        [indicator removeFromSuperview];
    }];
    
    // Start Loading Indicator
    [commentsRefresher beginRefreshing];
    loadingIndicator.alpha = 1;
    [loadingIndicator startAnimating];
}


#pragma mark - UIRefreshControl Stuff
-(void)endRefreshing:(UIRefreshControl *)refresher {
    [refresher endRefreshing];
    loadingIndicator.alpha = 0;
    [loadingIndicator stopAnimating];
}


#pragma mark - Vote for HNObject
-(void)voteForPost:(Post *)post {
    [HNService voteUp:YES forObject:post];
}

-(void)webservice:(Webservice *)webservice didVoteWithSuccess:(BOOL)success forObject:(id)object direction:(BOOL)up {
    if (success) {
        [[HNSingleton sharedHNSingleton] addToVotedForDictionary:object votedUp:up];
        [frontPageTable reloadData];
    }
    else {
        
    }
}

#pragma mark - TableView Delegate
-(int)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == frontPageTable) {
        return homePagePosts.count;
    }
    
    else {
        if (organizedCommentsArray.count > 0) {
            return organizedCommentsArray.count;
        }
        else {
            return 1;
        }
    }
}

UIView *_tableViewCellContainerView;
UIView *_contentView;

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Front Page
    if (tableView == frontPageTable) {
        
        if (indexPath.row == 0) {
            UITableViewCell *cellView = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
            cellView.backgroundColor = [UIColor clearColor];
            return cellView;
        }
        
        NSString *CellIdentifier = @"frontPageCell";
        frontPageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"frontPageCell" owner:nil options:nil];
            for (UIView *view in views) {
                if([view isKindOfClass:[UITableViewCell class]]) {
                    cell = (frontPageCell *)view;
                }
            }
        }
        
        cell = [cell setCellWithPost:(homePagePosts.count > 0 ? homePagePosts[indexPath.row] : nil) atIndex:indexPath fromController:self];
        
        return cell;
    }
    
    // Comments Cell
    else  {
        NSString *CellIdentifier = [NSString stringWithFormat:@"Cell %d", indexPath.row];
        CommentsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"CommentsCell" owner:nil options:nil];
            for (UIView *view in views) {
                if([view isKindOfClass:[UITableViewCell class]]) {
                    cell = (CommentsCell *)view;
                }
            }
        }
        
        cell = [cell cellForComment:(organizedCommentsArray.count > 0 ? organizedCommentsArray[indexPath.row] : nil) atIndex:indexPath fromController:self];
        
        return cell;
    }
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return NO;
    }
    return YES;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == frontPageTable) {
        if (indexPath.row == 0) {
            return;
        }
        // Set Current Post
        currentPost = homePagePosts[indexPath.row];
        
        // Mark As Read
        currentPost.HasRead = YES;
        [[HNSingleton sharedHNSingleton].hasReadThisArticleDict setValue:@"YES" forKey:currentPost.link];
        
        // Launch LinkView
        [self launchLinkView];
        
        // Reload table so Mark As Read will show up
        [frontPageTable reloadData];
        
        // Show header if it's offscreen
        [UIView animateWithDuration:0.25 animations:^{
            [self placeHeaderBarBack];
        }];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Comment Cell Height
    if (tableView == commentsTable) {
        NSString *CellIdentifier = [NSString stringWithFormat:@"Cell %d", indexPath.row];
        CommentsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"CommentsCell" owner:nil options:nil];
            for (UIView *view in views) {
                if([view isKindOfClass:[UITableViewCell class]]) {
                    cell = (CommentsCell *)view;
                }
            }
        }
        
        return [cell heightForComment:(organizedCommentsArray.count > 0 ? organizedCommentsArray[indexPath.row] : nil)];
    }
    
    // Front Page Cell Height
    else {
        if (indexPath.row == 0) {
            return 250;
        }
        if ([[homePagePosts objectAtIndex:indexPath.row] isOpenForActions]) {
            return kFrontPageActionsHeight;
        }
        return kFrontPageCellHeight  + 20 ;//+ MAX(0, title.length - 60);
    }
}

-(void)hideNestedCommentsCell:(UIButton *)commentButton {
    NSMutableArray *rowArray = [@[] mutableCopy];
    Comment *clickComment = organizedCommentsArray[commentButton.tag];
    
    // Close Comment and make hidden all nested Comments
    if (clickComment.CellType == CommentTypeOpen) {
        clickComment.CellType = CommentTypeClickClosed;
        [rowArray addObject:[NSIndexPath indexPathForRow:commentButton.tag inSection:0]];
        
        for (int xx = commentButton.tag + 1; xx < organizedCommentsArray.count; xx++) {
            Comment *newComment = organizedCommentsArray[xx];
            if (newComment.Level > clickComment.Level) {
                newComment.CellType = CommentTypeHidden;
                [rowArray addObject:[NSIndexPath indexPathForRow:xx inSection:0]];
            }
            else {
                break;
            }
        }
    }
    
    // Open Comment and all nested Comments
    else {
        clickComment.CellType = CommentTypeOpen;
        [rowArray addObject:[NSIndexPath indexPathForRow:commentButton.tag inSection:0]];
        
        for (int xx = commentButton.tag + 1; xx < organizedCommentsArray.count; xx++) {
            Comment *newComment = organizedCommentsArray[xx];
            if (newComment.Level > clickComment.Level) {
                newComment.CellType = CommentTypeOpen;
                [rowArray addObject:[NSIndexPath indexPathForRow:xx inSection:0]];
            }
            else {
                break;
            }
        }
    }
    
    // Reload the table with a nice animation
    [commentsTable reloadRowsAtIndexPaths:rowArray withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Table Gesture Recognizers
-(void)longPressFrontPageCell:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if ([HNSingleton sharedHNSingleton].User) {
            NSIndexPath *indexPath = [frontPageTable indexPathForRowAtPoint:[recognizer locationInView:frontPageTable]];
            if (indexPath) {
                if ([[homePagePosts objectAtIndex:indexPath.row] isOpenForActions]) {
                    [[homePagePosts objectAtIndex:indexPath.row] setIsOpenForActions:NO];
                    [frontPageTable reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    openFrontPageCells = [@[] mutableCopy];
                }
                else {
                    for (NSIndexPath *index in openFrontPageCells) {
                        Post *post = homePagePosts[index.row];
                        post.isOpenForActions = NO;
                    }
                    [[homePagePosts objectAtIndex:indexPath.row] setIsOpenForActions:YES];
                    [openFrontPageCells addObject:indexPath];
                    [frontPageTable reloadRowsAtIndexPaths:openFrontPageCells withRowAnimation:UITableViewRowAnimationFade];
                    openFrontPageCells = [@[indexPath] mutableCopy];
                }
            }
        }
    }
}

-(void)commentCellTapGesture:(UITapGestureRecognizer *)recognizer {
    NSIndexPath *indexPath = [commentsTable indexPathForRowAtPoint:[recognizer locationInView:commentsTable]];
    CommentsCell *cell = (CommentsCell *)[commentsTable cellForRowAtIndexPath:indexPath];
    CFIndex tapIndex = [cell.comment characterIndexAtPoint:[recognizer locationInView:cell.comment]];
    CGPoint recPoint = [recognizer locationInView:cell.comment];
    NSLog(@"Label Click: %f", recPoint.y);
    NSLog(@"%ld", tapIndex);
    CGRect textFrame = [cell.comment textRectForBounds:cell.comment.bounds limitedToNumberOfLines:cell.comment.numberOfLines];
    NSLog(@"%@ vs. %@", NSStringFromCGRect(cell.comment.frame), NSStringFromCGRect(textFrame));
}

#pragma mark - Front Page Voting Actions
-(void)voteUp:(UIButton *)voteButton {
    if ([HNSingleton sharedHNSingleton].User) {
        [HNService voteUp:YES forObject:[homePagePosts objectAtIndex:voteButton.tag]];
    }
}

-(void)voteDown:(UIButton *)voteButton {
    if ([HNSingleton sharedHNSingleton].User) {
        [HNService voteUp:NO forObject:[homePagePosts objectAtIndex:voteButton.tag]];
    }
}

#pragma mark - Launch/Hide Comments & Link View
-(void)didClickCommentsFromHomepage:(UIButton *)commentButton {
    currentPost = [homePagePosts objectAtIndex:commentButton.tag];
    [self loadCommentsForPost:currentPost];
}

-(void)launchCommentsView {
    // Set Post-Title Label
    postTitleLabel.text = currentPost.Title;
    
    // Set frames
    commentsView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    commentsHeader.frame = CGRectMake(0, 0, commentsHeader.frame.size.width, commentsHeader.frame.size.height);
    commentsTable.frame = CGRectMake(0, commentsHeader.frame.size.height, commentsView.frame.size.width, commentsView.frame.size.height - commentsHeader.frame.size.height);
    
    // Add to self.view
    [self.view addSubview:commentsView];
    [self.view bringSubviewToFront:commentsView];
    
    // Scroll to Top
    [commentsTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    // Animate everything
    [UIView animateWithDuration:0.3 animations:^{
        [frontPageTable setScrollEnabled:NO];
        [frontPageTable setContentOffset:frontPageTable.contentOffset animated:NO];
        commentsView.frame = CGRectMake(0, 0, commentsView.frame.size.width, self.view.frame.size.height);
    } completion:^(BOOL fin){
        [frontPageTable setScrollEnabled:YES];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }];
}

- (IBAction)hideCommentsAndLinkView:(id)sender {
    // Stop the linkWebView from loading
    // - Wrapped in the delegate-killer to prevent any
    // - animations from happening after.
    linkWebView.delegate = nil;
    [linkWebView stopLoading];
    linkWebView.delegate = self;
    
    // These make sure the comments don't re-open after closing
    if ([commentsTable isDragging]) {
        [commentsTable setContentOffset:commentsTable.contentOffset animated:NO];
    }
    if (commentsTable.contentOffset.y < 0  || commentsTable.contentSize.height <= self.view.frame.size.height){
        [commentsTable setContentOffset:CGPointZero animated:NO];
    }
    
    loadingIndicator.alpha = 0;
    [loadingIndicator stopAnimating];
    
    [self placeHeaderBarBack];
        self.navigationController.navigationBarHidden = YES;
    // Animate everything
    [UIView animateWithDuration:0.3 animations:^{
        commentsView.frame = CGRectMake(0, self.view.frame.size.height, commentsView.frame.size.width, frontPageTable.frame.size.height);
        linkView.frame = CGRectMake(0, self.view.frame.size.height, linkView.frame.size.width, linkView.frame.size.height);
    } completion:^(BOOL fin){
//        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }];
}

- (IBAction)showSharePanel:(id)sender {	
	NSURL *urlToShare = linkWebView.request.URL;
	NSArray *activityItems = @[ urlToShare ];
	
    ARChromeActivity *chromeActivity = [[ARChromeActivity alloc] init];	
	TUSafariActivity *safariActivity = [[TUSafariActivity alloc] init];
	NSArray *applicationActivities = @[ safariActivity, chromeActivity ];
	
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:applicationActivities];
	//activityController.excludedActivityTypes = @[ UIActivityTypePostToFacebook, UIActivityTypePostToTwitter, UIActivityTypePostToWeibo, UIActivityTypeMessage, UIActivityTypeMail, UIActivityTypeCopyToPasteboard ];
	
    [self presentViewController:activityController animated:YES completion:nil];
}

// Shows header bar
-(void)placeHeaderBarBack {
    headerContainer.frame = CGRectMake(0, 0, headerContainer.frame.size.width, headerContainer.frame.size.height);
}

- (IBAction)didClickLinkViewFromComments:(id)sender {
    currentPost.HasRead = YES;
    [[HNSingleton sharedHNSingleton].hasReadThisArticleDict setValue:@"YES" forKey:currentPost.PostID];
    [self launchLinkView];
    [frontPageTable reloadData];
}

- (IBAction)didClickCommentsFromLinkView:(id)sender {
    // Drop in Header
    [UIView animateWithDuration:0.25 animations:^{
        linkView.frame = CGRectMake(0, 0, linkView.frame.size.width, linkView.frame.size.height);
    }];
    
    // Stop LinkView from Opening/Loading anymore
    linkWebView.delegate = nil;
    [linkWebView stopLoading];
    linkWebView.delegate = self;

    //Empty Current Comments
    organizedCommentsArray = nil;

    //Start Fetching
    [self reloadComments];

    //Reload table to remove old comments

    [commentsTable reloadData];
    
    // Launch the comments
    [self launchCommentsView];
}

-(void)launchLinkView {
    // Stop comments from moving after clicking
    if ([commentsTable isDragging]) {
        [commentsTable setContentOffset:commentsTable.contentOffset animated:NO];
    }
    
    // Drop header back in
    [UIView animateWithDuration:0.25 animations:^{
        headerContainer.frame = CGRectMake(0, 0, headerContainer.frame.size.width, headerContainer.frame.size.height);
        commentsView.frame = CGRectMake(0, 0, commentsView.frame.size.width, commentsView.frame.size.height);
    }];
    
    // Reset WebView
    [linkWebView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML = \"\";"];
    
    // Set linkView's frame
    linkView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    linkHeader.frame = CGRectMake(0, 0, linkHeader.frame.size.width, linkHeader.frame.size.height);
    linkWebView.frame = CGRectMake(0, linkHeader.frame.size.height, linkWebView.frame.size.width, linkView.frame.size.height - linkHeader.frame.size.height);
    
    // Add linkView and move to front
    [self.view addSubview:linkView];
    [self.view bringSubviewToFront:linkView];
    
    linkViewLoadingIndicator.alpha = 1;
    // Animate it coming in
    [UIView animateWithDuration:0.3 animations:^{
        linkView.frame = CGRectMake(0, 0, linkView.frame.size.width, linkView.frame.size.height);
    } completion:^(BOOL finished) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:linkView action:@selector(doubleTap:)];
        doubleTap.numberOfTouchesRequired = 2;
        [linkView addGestureRecognizer:doubleTap];
        [linkWebView addGestureRecognizer:doubleTap];
        
        // Determine if using Readability, and load the webpage
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Readability"]) {
            
            // make webview render using local css
            NSString* myFile = currentPost.link;
            NSString* myFileURLString = [myFile stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

            [self ayncLoadHttpRequest:myFileURLString];
           
        }else {
            linkViewLoadingIndicator.alpha = 0;
            [linkWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:currentPost.link]]];
        }
    }];
    }

#pragma mark - aync load http request

NSMutableData *responseData;

- (void)ayncLoadHttpRequest:(NSString*)urlString
{
    
    NSURL *myURL = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL cachePolicy:NSURLCacheStorageAllowed timeoutInterval:60];
    
    [NSURLConnection connectionWithRequest:request delegate:self];

}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [FailedLoadingView launchFailedLoadingInView:self.view];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    TFHpple * doc       = [[TFHpple alloc] initWithHTMLData:responseData encoding:@"gbk"];
    NSArray * elements  = [doc searchWithXPathQuery:@"//div[@class='tpc_content']"];
    NSArray * autherElements  = [doc searchWithXPathQuery:@"//th[@class='r_two']"];
    if(elements && elements.count>0){
        TFHppleElement * element = [elements objectAtIndex:0];
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSURL *baseURL = [NSURL fileURLWithPath:path];
        NSString *template = @"<html lang=\"en\" xmlns=\"http://www.w3.org/1999/xhtml\" xmlns:fb=\"https://www.facebook.com/2008/fbml\" itemscope=\"itemscope\" itemtype=\"http://schema.org/Product\"><head prefix=\"og: http://ogp.me/ns# nodejsexpressdemo: http://ogp.me/ns/apps/nodejsexpressdemo#\"><meta charset=\"utf-8\"><meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge,chrome=1\"><title>detail</title><meta http-equiv=\"Content-type\" content=\"text/html;charset=UTF-8\"><meta name=\"keywords\" content=\"test\"><meta name=\"description\" content=\"test\"><meta name=\"viewport\" content=\"width=device-width,initial-scale=1\"><link href=\"bootstrap.min.css\" rel=\"stylesheet\"><link rel=\"stylesheet\" href=\"bootstrap-responsive.min.css\"><link href=\"prettify.css\" rel=\"stylesheet\"><link rel=\"stylesheet\" href=\"app.css\"></head><body data-spy=\"scroll\" data-target=\".bs-docs-sidebar\"><div class=\"wrapper\"><div class=\"container\"><div class=\"main-content\"><div class=\"main-head\">__CONTENT_TO_BE_REPLACED__</div></div></div><div class=\"wrapper\"><div class=\"container\"><div class=\"main-content\"><div class=\"main-head\"><div class=\"row-fluid\"><ul class=\"container\"><h4>Author:</h4>__AUTHER_TO_BE_REPLACED__</ul></div></div></div></div></br></br><div class=\"wrapper\"><div class=\"container\"><div class=\"main-content\"><div class=\"main-head\"><h4> Comments:</h4>__COMMENT_CONTENT_TO_BE_REPLACED__</div></div></div></body></html>";
        
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"input\\stype=['|\"]image['|\"]" options:NSRegularExpressionCaseInsensitive error:&error];
        NSRegularExpression *regexOfOnClick = [NSRegularExpression regularExpressionWithPattern:@"onclick=\"[^\"]*;\"" options:NSRegularExpressionCaseInsensitive error:&error];
        
        NSString *modifiedString = [regex stringByReplacingMatchesInString:[element raw] options:0 range:NSMakeRange(0, [[element raw] length]) withTemplate:@"img style=\"cursor:pointer\""];
        
        modifiedString = [regexOfOnClick stringByReplacingMatchesInString:modifiedString options:0 range:NSMakeRange(0, [modifiedString length]) withTemplate:@""];
        
        NSString *rendered =  [template stringByReplacingOccurrencesOfString:@"__CONTENT_TO_BE_REPLACED__" withString:modifiedString];
        
        if (autherElements && autherElements.count>0) {
            TFHppleElement * autherelement = [autherElements objectAtIndex:0];
            rendered =  [rendered stringByReplacingOccurrencesOfString:@"__AUTHER_TO_BE_REPLACED__" withString:[autherelement raw]];
        }else{
            rendered =  [rendered stringByReplacingOccurrencesOfString:@"__AUTHER_TO_BE_REPLACED__" withString:currentPost.author];
        }
        NSMutableString *commentsTobeReplaced = [@"" mutableCopy];
        
        for (int i=1;i<elements.count;i++) {
            [commentsTobeReplaced appendString:@"<div class=\"row-fluid\">"];
            [commentsTobeReplaced appendString:@"<div class=\"span12\">"];
            if (i < autherElements.count-1) {
                //                         NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"width=['|\"]\\d+%['|\"]\\srowspan=['|\"]\\d+['|\"]\\sclass=['|\"]r_two['|\"]" options:NSRegularExpressionCaseInsensitive error:&error];
                //                        [commentsTobeReplaced appendString:[regex stringByReplacingMatchesInString:[autherElements[i] raw] options:0 range:NSMakeRange(0, [[autherElements[i] raw] length]) withTemplate:@"width=\"100%\""]];
                [commentsTobeReplaced appendString:[autherElements[i] raw]];
            }
            [commentsTobeReplaced appendString:@"</div><div class=\"span12\"><p class=\"text-success\">"];
            [commentsTobeReplaced appendString:[elements[i] raw]];
            [commentsTobeReplaced appendString:@"</p></div>"];
            [commentsTobeReplaced appendString:@"</div><br></br>"];
        }
        
        if (commentsTobeReplaced.length>0) {
            rendered =  [rendered stringByReplacingOccurrencesOfString:@"__COMMENT_CONTENT_TO_BE_REPLACED__" withString:commentsTobeReplaced];
        }else{
            rendered =  [rendered stringByReplacingOccurrencesOfString:@"__COMMENT_CONTENT_TO_BE_REPLACED__" withString:@""];
        }
        
        [linkWebView loadHTMLString:rendered baseURL:baseURL];
        linkViewLoadingIndicator.alpha = 0;
    }else{
        linkViewLoadingIndicator.alpha = 0;
        [linkWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:currentPost.link]]];
    }
    

}


UIActionSheet *_actionActionSheet;
NSString *selectedImageURL;

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        //  <Find HTML tag which was clicked by user>
        //  <If tag is IMG, then get image URL and start saving>
        
        CGPoint pt = [gestureRecognizer locationInView:linkWebView];
        
        CGSize viewSize = [linkWebView frame].size;
        CGSize windowSize;
        windowSize.width = [[linkWebView stringByEvaluatingJavaScriptFromString:@"window.innerWidth"] integerValue];
        windowSize.height = [[linkWebView stringByEvaluatingJavaScriptFromString:@"window.innerHeight"] integerValue];
       
       
        
        CGFloat f = windowSize.width / viewSize.width;
        
        if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 5.0) {
            pt.x = pt.x * f;
            pt.y = pt.y * f;
        } else {
            // On iOS 4 and previous, document.elementFromPoint is not taking
            // offset into account, we have to handle it
            CGPoint offsetpt;
            offsetpt.x = [[linkWebView stringByEvaluatingJavaScriptFromString:@"window.pageXOffset"] integerValue];
            offsetpt.y = [[linkWebView stringByEvaluatingJavaScriptFromString:@"window.pageYOffset"] integerValue];
            pt.x = pt.x * f + offsetpt.x;
            pt.y = pt.y * f + offsetpt.y;
        }
        
        NSString *js = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).tagName", pt.x, pt.y];
      
        NSString * tagName = [linkWebView stringByEvaluatingJavaScriptFromString:js];
        if ([tagName isEqualToString:@"img"] || [tagName isEqualToString:@"IMG"]) {
            NSString *imgURL = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", pt.x, pt.y];
            NSString *urlToSave = [linkWebView stringByEvaluatingJavaScriptFromString:imgURL];
            NSLog(@"image url=%@", urlToSave);
            selectedImageURL = urlToSave;
            [self openContextualMenuAt:pt];
          
        }
    }
}

- (void)openContextualMenuAt:(CGPoint)pt{
    // Load the JavaScript code from the Resources and inject it into the web page
    
    if (!_actionActionSheet) {
        _actionActionSheet = nil;
    }
    _actionActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                     delegate:self
                                            cancelButtonTitle:nil
                                       destructiveButtonTitle:nil
                                            otherButtonTitles:nil];
    
    [_actionActionSheet addButtonWithTitle:@"Save Image"];
    [_actionActionSheet addButtonWithTitle:@"Copy Image"];
    [_actionActionSheet addButtonWithTitle:@"Save As Backgroud"];
    [_actionActionSheet addButtonWithTitle:@"Cancel"];
    [_actionActionSheet showInView:linkView];
    
}


#pragma UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Copy Image"]){
        
        NSOperationQueue *queue = [NSOperationQueue new];
        NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                selector:@selector(copyImage:) object:selectedImageURL];
        [queue addOperation:operation];
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Save Image"]){
        NSOperationQueue *queue = [NSOperationQueue new];
        NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                selector:@selector(saveImageURL:) object:selectedImageURL];
        [queue addOperation:operation];
    }else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Save As Backgroud"]){
        NSOperationQueue *queue = [NSOperationQueue new];
        NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                selector:@selector(SaveImageAsBackgroud:) object:selectedImageURL];
        [queue addOperation:operation];
    }
}


-(void)copyImage:(NSString*)url{
    
    NSURL *iUrl = [NSURL URLWithString:url];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:iUrl]];
    [[UIPasteboard generalPasteboard] setImage:image];
    
}
-(void)saveImageURL:(NSString*)url{
    
    UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]], nil, nil, nil);
  
}

-(void)SaveImageAsBackgroud:(NSString*)url{
    
    NSURL *iUrl = [NSURL URLWithString:url];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:iUrl]];
    [bgPhotoMgr setBackgroudImageWithImage:image andRomoveAllOtherImages:NO];
}

#pragma mark - External Link View
-(void)didClickExternalLinkInComment:(LinkButton *)linkButton {
    Comment *clickComment = organizedCommentsArray[linkButton.tag];
    [self launchExternalLinkViewWithLink:[clickComment.Links[linkButton.LinkTag] URL]];
}

-(void)launchExternalLinkViewWithLink:(NSURL *)linkUrl {
    // Set up External Link View
    [externalLinkWebView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML = \"\";"];
    [externalLinkWebView loadRequest:[NSURLRequest requestWithURL:linkUrl]];
    
    // Launch Link View
    externalLinkView.frame = CGRectMake(0, self.view.frame.size.height, externalLinkView.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:externalLinkView];
    [UIView animateWithDuration:0.25 animations:^{
        externalLinkView.frame = CGRectMake(0, 0, externalLinkView.frame.size.width, self.view.frame.size.height);
    }];
}

-(void)hideExternalLinkView {
    [UIView animateWithDuration:0.25 animations:^{
        externalLinkView.frame = CGRectMake(0, self.view.frame.size.height, externalLinkView.frame.size.width, self.view.frame.size.height);
    }];
}

- (IBAction)didClickBackToComments:(id)sender {
    [self hideExternalLinkView];
}

#pragma mark - WebView Delegate
-(void)webViewDidStartLoad:(UIWebView *)webView {
    if (webView == externalLinkWebView) {
        externalActivityIndicator.alpha = 1;
    }
    else {
        loadingIndicator.alpha = 1;
    }
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    if (webView == externalLinkWebView) {
        externalActivityIndicator.alpha = 0;
    }
    else {
        loadingIndicator.alpha = 0;
        [UIView animateWithDuration:0.25 animations:^{
            headerContainer.frame = CGRectMake(0, -1*headerContainer.frame.size.height, headerContainer.frame.size.width, headerContainer.frame.size.height);
            linkView.frame = CGRectMake(0, 0, linkView.frame.size.width,self.view.frame.size.height);
        }];
    }
}

@end
