//
//  UnpreventableUILongPressGestureRecognizer.m
//  HackerNews
//
//  Created by Ji Liang on 9/30/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "UnpreventableUILongPressGestureRecognizer.h"

@implementation UnpreventableUILongPressGestureRecognizer
- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer {
    return NO;
}
@end
