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
@synthesize commitUrl;
@synthesize author;
@synthesize committer;
@synthesize message;
@synthesize parentUrls;
@synthesize parentCommitShas;
@synthesize sha;
@synthesize deletions;
@synthesize additions;
@synthesize total;
@synthesize committedDate;
@synthesize authoredDate;


-(id)initMinimalDataWithJSONObject:(NSDictionary *)jsonObject {
    self = [super init];
    if (self) {
        self.commitUrl = [jsonObject objectForKey:@"url"];

        NSDictionary* jsonCommit = [jsonObject objectForKey:@"commit"];
        
        NSDictionary* tree = [jsonCommit objectForKey:@"tree"];
        self.treeUrl = [tree objectForKey:@"url"];
        
        id jsonAuthor = [jsonCommit valueForKey:@"author"];
        if (jsonAuthor != [NSNull null]) {
            self.author = [[[Person alloc] initWithJSONObject:jsonAuthor] autorelease];
        }

        self.message = [jsonCommit objectForKey:@"message"];

        NSArray* parents = [jsonObject objectForKey:@"parents"];
        NSMutableArray* newParentUrls = [[[NSMutableArray alloc] init] autorelease];
        NSMutableArray* newParentShas = [[[NSMutableArray alloc] init] autorelease];
        
        for (NSDictionary* parent in parents) {
            [newParentUrls addObject:[parent objectForKey:@"url"]];
            [newParentShas addObject:[parent objectForKey:@"sha"]];
        }
        self.parentUrls = newParentUrls;
        self.parentCommitShas = newParentShas;
    }
    return self;
}

-(id)initWithJSONObject:(NSDictionary*)jsonObject {
    self = [super init];
    if (self) {
        self.commitUrl = [jsonObject objectForKey:@"url"];
        self.sha = [jsonObject objectForKey:@"sha"];
        
        NSDictionary* jsonCommit = [jsonObject objectForKey:@"commit"];

        NSDictionary* tree = [jsonCommit objectForKey:@"tree"];
        self.treeUrl = [tree objectForKey:@"url"];

        id jsonAuthor = [jsonCommit valueForKey:@"author"];
        if (jsonAuthor != [NSNull null]) {
            self.author = [[[Person alloc] initWithJSONObject:jsonAuthor] autorelease];
            self.authoredDate = [jsonAuthor objectForKey:@"date"];
        }
        id jsonCommitter = [jsonCommit valueForKey:@"author"];
        if (jsonCommitter != [NSNull null]) {
            self.committer = [[[Person alloc] initWithJSONObject:jsonCommitter] autorelease];
            self.committedDate = [jsonCommitter objectForKey:@"date"];
        }
        
        self.message = [jsonCommit objectForKey:@"message"];
        
        NSDictionary* files = [jsonObject objectForKey:@"files"];

        NSDictionary* stats = [jsonObject objectForKey:@"stats"];
        self.deletions = ((NSNumber*)[stats objectForKey:@"deletions"]).intValue;
        self.additions = ((NSNumber*)[stats objectForKey:@"additions"]).intValue;
        self.total = ((NSNumber*)[stats objectForKey:@"total"]).intValue;
        
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
    [parentCommitShas release];
    [sha release];
    [committedDate release];
    [authoredDate release];
    [super dealloc];
}
@end
