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
@synthesize author;
@synthesize committer;
@synthesize message;
@synthesize parentUrls;

-(id)initWithJSONObject:(NSDictionary*)jsonObject {
    self = [super init];
    if (self) {
        
        NSDictionary* jsonCommit = [jsonObject objectForKey:@"commit"];

        NSDictionary* tree = [jsonCommit objectForKey:@"tree"];
        self.treeUrl = [tree objectForKey:@"url"];

        id jsonAuthor = [jsonCommit valueForKey:@"author"];
        if (jsonAuthor != [NSNull null]) {
            self.author = [[[Person alloc] initWithJSONObject:jsonAuthor] autorelease];
        }
        id jsonCommitter = [jsonCommit valueForKey:@"author"];
        if (jsonCommitter != [NSNull null]) {
            self.committer = [[[Person alloc] initWithJSONObject:jsonCommitter] autorelease];
        }
        
        self.message = [jsonCommit objectForKey:@"message"];
        
        NSDictionary* files = [jsonObject objectForKey:@"files"];
        NSDictionary* stats = [jsonObject objectForKey:@"stats"];
        
//        for (NSString* key in jsonObject.keyEnumerator) {
//            NSLog(@"Key: %@", key);
//            NSObject* value = [jsonObject objectForKey:key];
//            NSLog(@"Value: %@", value);
//        }
        
        NSArray* parents = [jsonObject objectForKey:@"parents"];
        NSMutableArray* newParentUrls = [[[NSMutableArray alloc] init] autorelease];
        
        for (NSDictionary* parent in parents) {
            [newParentUrls addObject:[parent objectForKey:@"url"]];
        }
        self.parentUrls = newParentUrls;
    }
    return self;
}

- (void)dealloc {
    [treeUrl release];
    [author release];
    [committer release];
    [message release];
    [parentUrls release];
    [super dealloc];
}
@end
