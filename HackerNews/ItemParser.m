//
//  ItemParser.m
//  HackerNews
//
//  Created by Ji Liang on 9/2/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "ItemParser.h"

@implementation ItemParser {
    NSMutableArray *_itemArray;
    NSMutableDictionary *_item;
    NSMutableDictionary *_newsitem;
    NSMutableDictionary *_adsitem;
    NSMutableDictionary *_attributesByElement;
    NSMutableString *_elementString;
    NSMutableArray * _itemsInField;
    NSString *_fliedName;
}
-(NSMutableArray *)itemData{
    return [_itemArray copy];
}

-(void)parserDidStartDocument:(NSXMLParser *)parser{
    _itemArray = [[NSMutableArray alloc] init];
    _item = [[NSMutableDictionary alloc] init];
    _elementString = [[NSMutableString alloc] init];
    _itemsInField=[[NSMutableArray alloc] init];
    _fliedName=[[NSString alloc] init];
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{

    [_elementString setString:@""];
}
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    // Save foundCharacters for later
    [_elementString appendString:string];
}
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    
    if ([elementName isEqualToString:@"item"]){
        
        [_itemArray addObject:[_item copy]];
        [_item removeAllObjects];
        
    } else if ([elementName isEqualToString:@"title"]) {
        [_item setObject:[_elementString copy] forKey:@"title"];
        
    }
    else if ([elementName isEqualToString:@"description"]) {
        [_item setObject:[_elementString copy] forKey:@"description"];
        
    }else if ([elementName isEqualToString:@"link"]) {
        [_item setObject:[_elementString copy] forKey:@"link"];
        
    }else if ([elementName isEqualToString:@"author"]) {
        [_item setObject:[_elementString copy] forKey:@"author"];
    }else if ([elementName isEqualToString:@"author"]) {
        [_item setObject:[_elementString copy] forKey:@"category"];
    }else if ([elementName isEqualToString:@"pubdate"]) {
        [_item setObject:[_elementString copy] forKey:@"pubdate"];
    }
    
    [_elementString setString:@""];
    
    }

-(void)parserDidEndDocument:(NSXMLParser *)parser{
    _elementString = nil;
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    NSLog(@"%@ with error %@",NSStringFromSelector(_cmd),parseError.localizedDescription);
}

-(BOOL)parse{
    self.delegate = self;
    return [super parse];
}
@end