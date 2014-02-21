//
//  UIUtil.h
//  Edentity
//
//  Created by Ji Liang on 11/15/13.
//  Copyright (c) 2013 Yahoo! Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


#define EAssertIsMain() NSAssert1([[NSThread currentThread] isMainThread], @"%s should always be called on main thread", __PRETTY_FUNCTION__)
#define EAssertIsNotMain() NSAssert1(![[NSThread currentThread] isMainThread], @"%s should never be called on main thread", __PRETTY_FUNCTION__)

@interface UIUtil : NSObject

+ (NSDateComponents*)getGMTDateComponentsFromDate:(NSDate*)date;
+(NSString*)getDisplayDateStringByDate:(NSDate*)date;
+ (BOOL)imageGoodToDisplayAsBackground:(UIImage*)image;

@end
