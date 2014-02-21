//
//  EBGPhotoManager.h
//  Edentity
//
//  Created by Ji Liang on 2/17/14.
//  Copyright (c) 2014 Yahoo! Inc. All rights reserved.
//


// Notifications
#define EPHOTO_ANIMOTION_END_NOTIFICATION @"EPHOTO_ANIMOTION_END_NOTIFICATION"

#import <Foundation/Foundation.h>

@interface EBGPhotoManager : NSObject

@property(nonatomic, strong) NSMutableArray *stockPhotoSet;

+ (EBGPhotoManager *) sharedManager;
- (void)reloadAllBackgroundCandidates;
- (void)setBackgroudImageWithImage:(UIImage*)image andRomoveAllOtherImages:(BOOL)removeAll;
- (void)setBackgroudImageWithImageArray:(NSArray*)imageArray andRomoveAllOtherImages:(BOOL)removeAll;
- (void) randomStockPhoto: (void (^)(NSDictionary *)) completion;
- (void)clearImagesCache;
@end
