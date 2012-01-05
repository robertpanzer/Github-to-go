//
//  Commit.m
//  Github To Go
//
//  Created by Robert Panzer on 04.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Commit.h"
#import <Foundation/Foundation.h>

@implementation Commit

@synthesize treeUrl;

-(id)initWithJSONObject:(NSDictionary*)jsonObject {
    self = [super init];
    if (self) {
        NSDictionary* tree = [jsonObject objectForKey:@"tree"];
        self.treeUrl = [tree objectForKey:@"url"];
    }
    return self;
}

- (void)dealloc {
    [treeUrl release];
    [super dealloc];
}
@end
