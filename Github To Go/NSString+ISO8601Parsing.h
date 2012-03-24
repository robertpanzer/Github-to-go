//
//  NSString+ISO8601Parsing.h
//  Github To Go
//
//  Created by Robert Panzer on 24.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ISO8601Parsing)

- (NSDate *)dateForRFC3339DateTimeString;

@end
