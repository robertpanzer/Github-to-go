//
//  Blob.m
//  Github To Go
//
//  Created by Robert Panzer on 05.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Blob.h"

@implementation Blob

@synthesize name;
@synthesize url;
@synthesize size;

-(id)initWithJSONObject:(NSDictionary*)jsonObject andName:(NSString*)aName {
    self = [super init];
    if (self) {
        self.name = aName;
        self.url = [jsonObject objectForKey:@"url"];
        size = [(NSNumber*)[jsonObject objectForKey:@"size"] longValue]; 
    }
    return self;
}

- (void)dealloc {
    [name release];
    [url release];
    [super dealloc];
}
@end
