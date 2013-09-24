//
//  Post.h
//  HackerNews
//
//  Created by Benjamin Gordon on 5/1/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Post : NSObject

@property (nonatomic,retain) NSString *ID;
@property (nonatomic,retain) NSString *Username;
@property (nonatomic, retain) NSString *URLString;
@property (nonatomic, retain) NSString *Title;
@property (nonatomic, retain) NSString *Description;
@property (nonatomic, retain) NSString *link;
@property (nonatomic, retain) NSString *author;
@property (nonatomic, retain) NSString *category;
@property (nonatomic, retain) NSString *pubdate;
@property (nonatomic, assign) int Points;
@property (nonatomic, assign) int CommentCount;
@property (nonatomic, retain) NSString *PostID;
@property (nonatomic, assign) BOOL HasRead;
@property (nonatomic, retain) NSDate *TimeCreated;
@property (nonatomic, retain) NSString *TimeCreatedString;
@property (nonatomic, retain) NSString *hnPostID;
@property (nonatomic, assign) BOOL isOpenForActions;
@property (nonatomic, assign) BOOL isJobPost;


+(Post *)postFromDictionary:(NSDictionary *)dict;
+(NSArray *)orderPosts:(NSMutableArray *)posts byItemIDs:(NSArray *)items;
+ (NSArray *)parsedFrontPagePostsFromRss:(NSString *)htmlString;

@end
