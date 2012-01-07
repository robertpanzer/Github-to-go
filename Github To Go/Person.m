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
@synthesize name;
@synthesize email;

- (id)initWithJSONObject:(NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        self.login = [dictionary objectForKey:@"login"];
        self.name = [dictionary objectForKey:@"name"];
        self.email = [dictionary objectForKey:@"email"];
    }
    return self;
}
- (void)dealloc {
    [login release];
    [name release];
    [email release];
    [super dealloc];
}
@end
