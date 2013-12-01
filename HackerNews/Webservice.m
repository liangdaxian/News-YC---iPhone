//
//  Webservice.m
//  HackerNews
//
//  Created by Benjamin Gordon with help by @MatthewYork on 4/28/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "Webservice.h"
#import "HNSingleton.h"
#import "HNOperation.h"
#import "TFHpple.h"

NSString * HOST = @"";
@implementation Webservice
@synthesize delegate;

-(id)init {
    self = [super init];
    self.HNOperationQueue = [[NSOperationQueue alloc] init];
    [self.HNOperationQueue setMaxConcurrentOperationCount:10];
    self.isLoadingFromFNID = NO;

    return self;
}

#pragma mark - Get Homepage

-(void)getHomepageWithFilter:(NSString *)filter withAddress:(NSString*)address WithSubPageIndex:(NSString*)subPageIndex success:(GetHomeSuccessBlock)success failure:(GetHomeFailureBlock)failure {
    HNOperation *operation = [[HNOperation alloc] init];
    NSString *addr = address;
    __weak HNOperation *weakOp = operation;
    NSString *urlString=[[NSString stringWithFormat: addr,filter,subPageIndex] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    
    [operation setUrlPath:urlString data:nil completion:^{
        NSString *responseString = [[NSString alloc] initWithData:weakOp.responseData encoding:enc];
        
        
        if (responseString.length > 0) {
            NSArray *posts = [Post parsedFrontPagePostsFromWebPage:responseString withHost:HOST];
            dispatch_async(dispatch_get_main_queue(), ^{
                success(posts);
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure();
            });
        }
        
        
    }];
    [self.HNOperationQueue addOperation:operation];
}

-(void)getHomepageWithFilter:(NSString *)filter withAddressNO:(int)address WithSubPageIndex:(int)subPageIndex success:(GetHomeSuccessBlock)success failure:(GetHomeFailureBlock)failure{
    
    HOST = @"http://cl.man.lv";
    NSString *addr1024 =  @"http://cl.man.lv/thread0806.php?fid=%@&page=%@";// default
    
    if (address-1 == AddressTypeDefault) {
        
          [self getHomepageWithFilter:filter withAddress:addr1024 WithSubPageIndex:[NSString stringWithFormat:@"%d",subPageIndex] success:success failure:failure];

        return;
        
    }
    HNOperation *operation = [[HNOperation alloc] init];
    
    NSString *addr =@"http://1024z.site44.com/";
    __weak HNOperation *weakOp = operation;
    
    NSString *urlString=[addr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [operation setUrlPath:urlString data:nil completion:^{
       
        HOST = @"http://cl.man.lv";
        NSString *addr1024 =  @"http://cl.man.lv/thread0806.php?fid=%@&page=%@";// default
        
        TFHpple * doc       = [[TFHpple alloc] initWithHTMLData:weakOp.responseData encoding:@"utf-16"];
        
        NSArray * elements  = [doc searchWithXPathQuery:@"//a[@target='_blank']"];
        if (elements && elements.count>0 && address<elements.count) {
            NSURL* url = [NSURL URLWithString:[elements[address] objectForKey:@"href"]];
            HOST = [@"http://" stringByAppendingString:url.host];
            addr1024 = [[@"http://" stringByAppendingString:url.host] stringByAppendingString:@"/thread0806.php?fid=%@page=%@"];
        }
        
        [self getHomepageWithFilter:filter withAddress:addr1024 WithSubPageIndex:[NSString stringWithFormat:@"%d",subPageIndex] success:success failure:failure];
        
    }];
    [self.HNOperationQueue addOperation:operation];
}

-(void)getHomepageFromFnid:(NSString *)fnid withSuccess:(GetHomeSuccessBlock)success failure:(GetHomeFailureBlock)failure {
    if (!self.isLoadingFromFNID) {
        self.isLoadingFromFNID = YES;
        
        if (fnid.length == 0) {
            success(@[]);
            return;
        }
        
        HNOperation *operation = [[HNOperation alloc] init];
        __weak HNOperation *weakOp = operation;
        [operation setUrlPath:[NSString stringWithFormat:@"https://news.ycombinator.com/%@", [fnid stringByReplacingOccurrencesOfString:@"/" withString:@""]] data:nil completion:^{
            NSString *responseString = [[NSString alloc] initWithData:weakOp.responseData encoding:NSUTF8StringEncoding];
            if (responseString.length > 0) {
                NSArray *posts = [Post parsedFrontPagePostsFromRss:responseString];
                dispatch_async(dispatch_get_main_queue(), ^{
                    success(posts);
                    self.isLoadingFromFNID = NO;
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure();
                    self.isLoadingFromFNID = NO;
                });
            }
        }];
        [self.HNOperationQueue addOperation:operation];
    }
}

-(void)grabPostsFromPath:(NSString *)path items:(NSArray *)items success:(GetHomeSuccessBlock)success failure:(GetCommentsFailureBlock)failure {
    HNOperation *operation = [[HNOperation alloc] init];
    __weak HNOperation *weakOp = operation;
    [operation setUrlPath:path data:nil completion:^{
        NSArray *responseArray = [NSJSONSerialization JSONObjectWithData:weakOp.responseData options:NSJSONReadingAllowFragments error:nil];
        if (responseArray) {
            NSMutableArray *postArray = [@[] mutableCopy];
            for (NSDictionary *dict in responseArray) {
                [postArray addObject:[Post postFromDictionary:dict]];
            }
            
            NSArray *orderedPostArray = [Post orderPosts:postArray byItemIDs:items];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                success(orderedPostArray);
                [self reloadUser];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure();
            });
            
        }
    }];
    [self.HNOperationQueue addOperation:operation];
}


#pragma mark - Get Comments
-(void)getCommentsForPost:(Post *)post success:(GetCommentsSuccessBlock)success failure:(GetCommentsFailureBlock)failure {
    HNOperation *operation = [[HNOperation alloc] init];
    __weak HNOperation *weakOp = operation;
    [operation setUrlPath:[NSString stringWithFormat:@"https://news.ycombinator.com/item?id=%@",post.hnPostID] data:nil completion:^{
        NSString *responseHTML = [[NSString alloc] initWithData:weakOp.responseData encoding:NSUTF8StringEncoding];
        if (responseHTML.length > 0) {
            NSArray *comments = [Comment commentsFromHTML:responseHTML];
            dispatch_async(dispatch_get_main_queue(), ^{
                success(comments);
                [self reloadUser];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure();
            });
        }
    }];
    [self.HNOperationQueue addOperation:operation];
}


#pragma mark - Login
-(void)loginWithUsername:(NSString *)user password:(NSString *)pass {
    HNOperation *operation = [[HNOperation alloc] init];
    __weak HNOperation *weakOp = operation;
    [operation setUrlPath:@"https://news.ycombinator.com/newslogin?whence=news" data:nil completion:^{
        NSString *responseString = [[NSString alloc] initWithData:weakOp.responseData encoding:NSStringEncodingConversionAllowLossy];
        if (responseString.length > 0) {
            NSString *fnid = @"", *trash = @"";
            NSScanner *fnidScan = [NSScanner scannerWithString:responseString];
            [fnidScan scanUpToString:@"name=\"fnid\" value=\"" intoString:&trash];
            [fnidScan scanString:@"name=\"fnid\" value=\"" intoString:&trash];
            [fnidScan scanUpToString:@"\"" intoString:&fnid];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (fnid.length > 0) {
                    [self makeLoginRequestWithUser:user password:pass fnid:fnid];
                }
                else {
                    [delegate webservice:self didLoginWithUser:nil];
                }
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate webservice:self didLoginWithUser:nil];
            });
        }
    }];
    [self.HNOperationQueue addOperation:operation];
}

-(void)makeLoginRequestWithUser:(NSString *)user password:(NSString *)pass fnid:(NSString *)fnid {
    // Create BodyData
    NSString *bodyString = [NSString stringWithFormat:@"fnid=%@&u=%@&p=%@",fnid,user,pass];
    NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    // Make Request
    HNOperation *operation = [[HNOperation alloc] init];
    __weak HNOperation *weakOp = operation;
    [operation setUrlPath:@"https://news.ycombinator.com/y" data:bodyData completion:^{
        NSString *responseString = [[NSString alloc] initWithData:weakOp.responseData encoding:NSStringEncodingConversionAllowLossy];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ contains[c] SELF", responseString];
        if ([predicate evaluateWithObject:@"Bad login."]) {
            // Login Failed
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate webservice:self didLoginWithUser:nil];
            });
        }
        else {
            // Set Defaults
            [[NSUserDefaults standardUserDefaults] setValue:user forKey:@"Username"];
            [[NSUserDefaults standardUserDefaults] setValue:pass forKey:@"Password"];
            
            // Pass User through the delegate
            dispatch_async(dispatch_get_main_queue(), ^{
                [self createUser:user];
            });
        }
    }];
    [self.HNOperationQueue addOperation:operation];
}


#pragma mark - User
-(void)createUser:(NSString *)user {
    HNOperation *operation = [[HNOperation alloc] init];
    __weak HNOperation *weakOp = operation;
    [operation setUrlPath:[NSString stringWithFormat:@"https://news.ycombinator.com/user?id=%@", user] data:nil completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate webservice:self didLoginWithUser:[User userFromHTMLString:[[NSString alloc] initWithData:weakOp.responseData encoding:NSStringEncodingConversionAllowLossy]]];
        });
    }];
    [self.HNOperationQueue addOperation:operation];
}

-(void)reloadUser {
    if ([HNSingleton sharedHNSingleton].User) {
        HNOperation *operation = [[HNOperation alloc] init];
        __weak HNOperation *weakOp = operation;
        [operation setUrlPath:[NSString stringWithFormat:@"https://news.ycombinator.com/user?id=%@", [HNSingleton sharedHNSingleton].User.Username] data:nil completion:^{
            if (weakOp.responseData) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [HNSingleton sharedHNSingleton].User = [User userFromHTMLString:[[NSString alloc] initWithData:weakOp.responseData encoding:NSStringEncodingConversionAllowLossy]];
                    [HNSingleton sharedHNSingleton].User.Username = [[NSUserDefaults standardUserDefaults] valueForKey:@"Username"];
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Failed
                });
            }
        }];
        [self.HNOperationQueue addOperation:operation];
    }
}


#pragma mark - Voting
-(void)voteUp:(BOOL)up forObject:(id)HNObject {
    // Get Voting ID
    NSString *hnID = @"";
    if ([HNObject isKindOfClass:[Post class]]) {
        Post *post = (Post *)HNObject;
        hnID = post.hnPostID;
    }
    else if ([HNObject isKindOfClass:[Comment class]]) {
        Comment *com = (Comment *)HNObject;
        hnID = com.hnCommentID;
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate webservice:self didVoteWithSuccess:NO forObject:nil direction:NO];
            return;
        });
    }
    
    // Make Request
    HNOperation *operation = [[HNOperation alloc] init];
    __weak HNOperation *weakOp = operation;
    [operation setUrlPath:[NSString stringWithFormat:@"https://news.ycombinator.com/item?id=%@",hnID] data:nil completion:^{
        NSString *responseString = [[NSString alloc] initWithData:weakOp.responseData encoding:NSStringEncodingConversionAllowLossy];
        if (responseString.length > 0) {
            // Create VoteURL
            NSScanner *scanner = [NSScanner scannerWithString:responseString];
            NSString *voteURL = @"";
            NSString *trash = @"";
            [scanner scanUpToString:[NSString stringWithFormat:@"id=up_%@", hnID] intoString:&trash];
            [scanner scanString:[NSString stringWithFormat:@"id=up_%@ onclick=\"return vote(this)\" href=\"", hnID] intoString:&trash];
            [scanner scanUpToString:@"\"" intoString:&voteURL];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self voteUp:up withPath:voteURL forObject:HNObject];
            });
        }
        else {
            // Voting failed
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate webservice:self didVoteWithSuccess:NO forObject:nil direction:NO];
            });
        }
    }];
    [self.HNOperationQueue addOperation:operation];
}

-(void)voteUp:(BOOL)up withPath:(NSString *)votePath forObject:(id)object {
    HNOperation *operation = [[HNOperation alloc] init];
    __weak HNOperation *weakOp = operation;
    [operation setUrlPath:[NSString stringWithFormat:@"https://news.ycombinator.com/%@", votePath] data:nil completion:^{
        NSString *responseString = [[NSString alloc] initWithData:weakOp.responseData encoding:NSStringEncodingConversionAllowLossy];
        if (responseString) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate webservice:self didVoteWithSuccess:YES forObject:object direction:up];
            });
        }
        else {
            // Voting failed
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate webservice:self didVoteWithSuccess:NO forObject:nil direction:up];
            });
        }
    }];
    [self.HNOperationQueue addOperation:operation];
}


#pragma mark - Submitting a Link
-(void)submitLink:(NSString *)urlPath orText:(NSString *)textPost title:(NSString *)title success:(SubmitLinkSuccessBlock)success failure:(SubmitLinkFailureBlock)failure {
    HNOperation *operation = [[HNOperation alloc] init];
    __weak HNOperation *weakOp = operation;
    [operation setUrlPath:@"https://news.ycombinator.com/submit" data:nil completion:^{
        NSString *responseString = [[NSString alloc] initWithData:weakOp.responseData encoding:NSStringEncodingConversionAllowLossy];
        if ([responseString rangeOfString:@"login"].location == NSNotFound) {
            NSString *trash = @"", *fnid = @"";
            NSScanner *scanner = [NSScanner scannerWithString:responseString];
            [scanner scanUpToString:@"name=\"fnid\" value=\"" intoString:&trash];
            [scanner scanString:@"name=\"fnid\" value=\"" intoString:&trash];
            [scanner scanUpToString:@"\"" intoString:&fnid];
            
            // Create BodyData
            NSString *bodyString;
            if (urlPath.length > 0) {
                bodyString = [NSString stringWithFormat:@"fnid=%@&u=%@&t=%@&x=\"\"", fnid, urlPath, title];
            }
            else {
                bodyString = [NSString stringWithFormat:@"fnid=%@&u=\"\"&t=%@&x=%@", fnid, title, textPost];
            }
            NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
            
            // Create next Request
            dispatch_async(dispatch_get_main_queue(), ^{
                [self submitData:bodyData success:success failure:failure];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure();
            });
        }
    }];
    [self.HNOperationQueue addOperation:operation];
}

-(void)submitData:(NSData *)bodyData success:(SubmitLinkSuccessBlock)success failure:(SubmitLinkFailureBlock)failure {
    HNOperation *operation = [[HNOperation alloc] init];
    __weak HNOperation *weakOp = operation;
    [operation setUrlPath:@"https://news.ycombinator.com/r" data:bodyData completion:^{
        NSString *responseString = [[NSString alloc] initWithData:weakOp.responseData encoding:NSStringEncodingConversionAllowLossy];
        if (responseString) {
            dispatch_async(dispatch_get_main_queue(), ^{
                success();
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure();
            });
        }
    }];
    [self.HNOperationQueue addOperation:operation];
}

#pragma mark - Lock FNID
- (void)lockFNIDLoading {
    self.isLoadingFromFNID = YES;
}

- (void)unlockFNIDLoading {
    self.isLoadingFromFNID = NO;
}


#pragma mark - Logging
-(void)logData:(NSData *)data {
    NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy]);
}

@end
