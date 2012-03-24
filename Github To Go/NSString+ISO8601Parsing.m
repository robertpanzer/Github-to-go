//
//  NSString+ISO8601Parsing.m
//  Github To Go
//
//  Created by Robert Panzer on 24.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString+ISO8601Parsing.h"

@implementation NSString (ISO8601Parsing)

- (NSDate *)dateForRFC3339DateTimeString
// Returns a user-visible date time string that corresponds to the 
// specified RFC 3339 date time string. Note that this does not handle 
// all possible RFC 3339 date time strings, just one of the most common 
// styles.
{
    if (self.length < 20) {
        return nil;
    }
    
    @try {
        NSString *dateString = [self substringToIndex:10];
        NSString *timeString = [self substringFromIndex:11];
        timeString = [timeString substringToIndex:8];
        NSString *timezoneString = [self substringFromIndex:19];
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        
        dateComponents.hour = [[timeString substringToIndex:2] intValue]; 
        dateComponents.second = [[timeString substringFromIndex:6] intValue]; 
        dateComponents.minute = [[timeString substringWithRange:NSMakeRange(3, 5)] intValue]; 
        
        dateComponents.year = [[dateString substringToIndex:4] intValue];
        dateComponents.month = [[self substringWithRange:NSMakeRange(5, 7)] intValue]; 
        dateComponents.day = [[dateString substringFromIndex:8] intValue]; 
        
        if ([timezoneString isEqualToString:@"Z"]) {
            dateComponents.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        } else if (timezoneString.length == 6) {
            NSInteger tzOffset = ([[timezoneString substringWithRange:NSMakeRange(1, 3)] intValue] * 3600);
            tzOffset += [[timezoneString substringFromIndex:4] intValue] * 60;
            if ([timezoneString hasPrefix:@"-"]) {
                tzOffset *= -1;
            }
            dateComponents.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:tzOffset];
        } else {
            NSLog(@"Unparseable date %@", self);
            return nil;
        }
        
        NSCalendar *gregorian = [[NSCalendar alloc]
                                 initWithCalendarIdentifier:NSGregorianCalendar];
        NSDate *ret = [gregorian dateFromComponents:dateComponents];
        return ret;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@ occured while parsing %@", exception, self);
        return nil;
    }
    
}

@end
