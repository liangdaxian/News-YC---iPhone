//
//  UIUtil.m
//  Edentity
//
//  Created by Ji Liang on 11/15/13.
//  Copyright (c) 2013 Yahoo! Inc. All rights reserved.
//

#import "UIUtil.h"


@implementation UIUtil

+ (NSDateComponents*)getGMTDateComponentsFromDate:(NSDate*)date{
    
    NSTimeInterval timeZoneOffset = [[NSTimeZone defaultTimeZone] secondsFromGMT];
    NSTimeInterval gmtTimeInterval = [date timeIntervalSinceReferenceDate] - timeZoneOffset;
    NSDate *gmtDate = [NSDate dateWithTimeIntervalSinceReferenceDate:gmtTimeInterval];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components = [[ NSCalendar currentCalendar] components:NSDayCalendarUnit |
                  NSMonthCalendarUnit | NSYearCalendarUnit fromDate:gmtDate];
    [components setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    return components;
}

+(BOOL)imageGoodToDisplayAsBackground:(UIImage*)image{
    
    if (image ==  nil) {
        return NO;
    }
    if ((image.size.width>=320 && image.size.height>=480)
        ||(image.size.height>=480 && image.size.width>=320)) {
        return YES;
    }
    return NO;
}

+(NSString*)getDisplayDateStringByDate:(NSDate*)date
{
    NSDateComponents *comp = [self getGMTDateComponentsFromDate:date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *newdate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%i-%i-%i", comp.year, comp.month, comp.day]];
    
    [dateFormatter setDateFormat:@"MM.d.yyyy"];
    return [dateFormatter stringFromDate:newdate];
}
@end
