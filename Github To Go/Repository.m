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
@synthesize owner;
@synthesize branches;

-(id) initFromJSONObject:(NSDictionary*)jsonObject {
    self = [super init];
    if (self) {
        self.name = [jsonObject objectForKey:@"name"];
        self.description = [jsonObject objectForKey:@"description"];
        if (![[jsonObject objectForKey:@"master_branch"] isKindOfClass:[NSNull class]]) {
            self.masterBranch = [jsonObject objectForKey:@"master_branch"];
        }
        self.branches = [[[NSMutableDictionary alloc] init] autorelease];
        NSLog(@"Masterbranch: %@", masterBranch);
        NSDictionary* ownerObject = (NSDictionary*)[jsonObject objectForKey:@"owner"];
        
        self.owner = [[[Person alloc] initWithJSONObject:ownerObject] autorelease];
        
        
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
        self.masterBranch = @"master";
    }
    return [branches valueForKey:self.masterBranch];
}

- (void)dealloc {
    [name release];
    [description release];
    [masterBranch release];
    [super dealloc];
}
@end
