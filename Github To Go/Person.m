//
//  Person.m
//  Github To Go
//
//  Created by Robert Panzer on 04.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Person.h"

@implementation Person 

@synthesize login;

- (id)initWithJSONObject:(NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        self.login = [dictionary objectForKey:@"login"];
    }
    return self;
}
- (void)dealloc {
    [login release];
    [super dealloc];
}
@end
