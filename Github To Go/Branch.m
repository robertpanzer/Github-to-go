//
//  Branch.m
//  Github To Go
//
//  Created by Robert Panzer on 06.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Branch.h"

@implementation Branch

@synthesize name;
@synthesize commitUrl;
@synthesize sha;

-(id)initWithJSONObject:(NSDictionary*)jsonObject {
    self = [super init];
    if (self) {
        self.name = [jsonObject objectForKey:@"name"];
        NSDictionary* commitObject = [jsonObject objectForKey:@"commit"];
        self.commitUrl = [commitObject objectForKey:@"url"];
        self.sha = [commitObject objectForKey:@"sha"];
    }
    return self;
}

- (void)dealloc {
    [name release];
    [commitUrl release];
    [super dealloc];
}

@end
