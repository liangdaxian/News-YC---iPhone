//
//  Post.m
//  HackerNews
//
//  Created by Benjamin Gordon on 5/1/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "Post.h"
#import "Helpers.h"
#import "HNSingleton.h"
#import "ItemParser.h"

@implementation Post

+(Post *)postFromDictionary:(NSDictionary *)dict {
    Post *newPost = [[Post alloc] init];
    
    // Set Data

    newPost.Title = [dict objectForKey:@"title"];
    newPost.Description =[dict objectForKey:@"title"];
    newPost.link =[dict objectForKey:@"link"];
    newPost.author =[dict objectForKey:@"author"];
    newPost.category =[dict objectForKey:@"category"];
    newPost.pubdate =[dict objectForKey:@"pubdate"];
    
//    newPost.Username = [dict objectForKey:@"username"];
//    newPost.PostID = [dict objectForKey:@"_id"];
//    newPost.hnPostID = [dict objectForKey:@"id"];
//    newPost.Points = [[dict objectForKey:@"points"] intValue];
//    newPost.CommentCount = [[dict objectForKey:@"num_comments"] intValue];
//
//    newPost.TimeCreated = [Helpers postDateFromString:[dict objectForKey:@"create_ts"]];
    newPost.isOpenForActions = NO;
    
    // Set URL for Ask HN
//    if ([dict objectForKey:@"url"] == [NSNull null]) {
//        newPost.URLString = [NSString stringWithFormat:@"http://news.ycombinator.com/item?id=%@", [dict objectForKey:@"id"]];
//    }
//    else {
//        newPost.URLString = [dict objectForKey:@"url"];
//    }
    
    // Mark as Read
    newPost.HasRead = [[HNSingleton sharedHNSingleton].hasReadThisArticleDict objectForKey:newPost.link] ? YES : NO;
    
    return newPost;
}

+(NSArray *)orderPosts:(NSMutableArray *)posts byItemIDs:(NSArray *)items {
    NSMutableArray *orderedPosts = [@[] mutableCopy];
    
    for (NSString *itemID in items) {
        for (Post *post in posts) {
            if ([post.PostID isEqualToString:itemID]) {
                [orderedPosts addObject:post];
                [posts removeObject:post];
                break;
            }
        }
    }
    
    return orderedPosts;
}

+ (NSArray *)parsedFrontPagePostsFromRss:(NSString *)htmlString {
    // Set up
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    
    NSData *data = [htmlString dataUsingEncoding:enc];
    
    ItemParser *parser = [[ItemParser alloc] initWithData:data];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];
    
    NSArray *parsedArray = [parser itemData];
    NSMutableArray *postArray = [[NSMutableArray alloc]init];
    if (parsedArray.count>0) {
        for (NSDictionary *dict in parsedArray) {
            [postArray addObject:[Post postFromDictionary:dict]];
        }
    }
    return postArray;
}


@end
