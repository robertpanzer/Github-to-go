//
//  Repository.m
//  TabBarTest
//
//  Created by Robert Panzer on 30.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Repository.h"
#import "NetworkProxy.h"

@implementation Repository

@synthesize name;
@synthesize description;
@synthesize masterBranch;
@synthesize url;
@synthesize owner;
@synthesize branches;
@synthesize repoId;
@synthesize watchers;
@synthesize private;
@synthesize fork;
@synthesize forks;

-(id) initFromJSONObject:(NSDictionary*)jsonObject {
    self = [super init];
    if (self) {
        self.name = [jsonObject objectForKey:@"name"];
        self.description = [jsonObject objectForKey:@"description"];
        if (![[jsonObject objectForKey:@"master_branch"] isKindOfClass:[NSNull class]]) {
            self.masterBranch = [jsonObject objectForKey:@"master_branch"];
        }

        self.branches = [[[NSMutableDictionary alloc] init] autorelease];

        NSDictionary* ownerObject = (NSDictionary*)[jsonObject objectForKey:@"owner"];
        self.owner = [[[Person alloc] initWithJSONObject:ownerObject] autorelease];

        self.repoId = [jsonObject valueForKey:@"id"];

        self.private = [[jsonObject valueForKey:@"private"] boolValue];
        
        self.watchers = [jsonObject valueForKey:@"watchers"];

        self.fork = [[jsonObject valueForKey:@"fork"] boolValue];

        self.forks = [jsonObject valueForKey:@"forks"];

        self.url = [jsonObject valueForKey:@"url"];
        
        for (NSString* key in jsonObject.keyEnumerator) {
            NSLog(@"Repo Key: %@", key);
        }
        
    }
    return self;    
}

- (void)setBranchesFromJSONObject:(NSArray*)jsonArray {
    for (NSDictionary* branch in jsonArray) {
        NSString* branchName = [branch valueForKey:@"name"];
        NSDictionary* commit = [branch valueForKey:@"commit"];
        NSString* commitUrl = [commit valueForKey:@"url"]; 
        [branches setValue:commitUrl forKey:branchName];
    }
}

- (NSString*) urlOfMasterBranch {
    if (self.branches.count == 0) {
        return nil;
    }
    if (self.masterBranch == nil) {
        return nil;
    }
    return [branches valueForKey:self.masterBranch];
}

- (NSString*)fullName {
    return [NSString stringWithFormat:@"%@/%@", self.owner.login, self.name];
}
- (void)dealloc {
    [name release];
    [description release];
    [masterBranch release];
    [owner release];
    [branches release];
    [repoId release];
    [forks release];
    [url release];
    [watchers release];
    [super dealloc];
}
@end
