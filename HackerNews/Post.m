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
#import <CommonCrypto/CommonDigest.h>
#import "TFHpple.h"

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
    newPost.ID = [self getSha1:newPost.Title];
    
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

+ (NSArray *)parsedFrontPagePostsFromWebPage:(NSString *)htmlString withHost:(NSString*)host {
    // Set up
    
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
   
    TFHpple * doc       = [[TFHpple alloc] initWithHTMLData:[htmlString dataUsingEncoding: enc] encoding:@"gbk"];
    
    NSArray * elements  = [doc searchWithXPathQuery:@"//a[@target='_blank' and contains(@href, 'htm_data')]"];
    NSMutableArray *postArray = [NSMutableArray array];

    if (elements && elements.count>0) {
        
        for (TFHppleElement *element in elements) {
            
            NSLog(@"href:%@",[element objectForKey:@"href"]);
            NSLog(@"content:%@",[[element firstChild] content]);
            NSLog(@"text:%@",[[element firstChild] text]);
            
            if ([[[element firstChild] content] isEqualToString:@".::"] || [[[element firstChild] text] isEqualToString:@".::"]){
                // abdon it
                NSLog(@"discard it");
                
            }else { // remove dulicate
                
                 NSDictionary *dict = [NSMutableDictionary dictionary];
                
                NSString *title = [[element firstChild] text];
                if (!title || title.length <=0) {
                    title = [[element firstChild] content];
                }
                [dict setValue:title forKey:@"title"];
                
                NSURL *url= [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",host ,[element objectForKey:@"href"]]];
                NSString* link = [[url standardizedURL]absoluteString];
                
                [dict setValue:link forKey:@"link"];
                [dict setValue:@"" forKey:@"author"];
                [postArray addObject:[Post postFromDictionary:dict]];
                
            }
        }
    }
    return postArray;
}

+ (NSString *)getSha1:(NSString*)input{
    
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}


@end
