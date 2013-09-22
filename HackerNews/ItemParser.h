//
//  ItemParser.h
//  HackerNews
//
//  Created by Ji Liang on 9/2/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#ifndef HackerNews_ItemParser_h
#define HackerNews_ItemParser_h

#import <Foundation/Foundation.h>
@interface ItemParser : NSXMLParser <NSXMLParserDelegate>
@property (readonly) NSMutableArray *itemData;
@end

#endif
