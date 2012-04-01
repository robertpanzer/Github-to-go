//
//  Repository.m
//  TabBarTest
//
//  Created by Robert Panzer on 30.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Repository.h"
#import "NetworkProxy.h"
#import "NSString+ISO8601Parsing.h"

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
@synthesize createdAt;
@synthesize language;
@synthesize openIssues;

-(id) initFromJSONObject:(NSDictionary*)jsonObject {
    self = [super init];
    if (self) {
        self.name = [jsonObject objectForKey:@"name"];
        self.description = [jsonObject objectForKey:@"description"];
        if (![[jsonObject objectForKey:@"master_branch"] isKindOfClass:[NSNull class]]) {
            self.masterBranch = [jsonObject objectForKey:@"master_branch"];
        }

        self.branches = [[NSMutableDictionary alloc] init];

        id ownerObject = [jsonObject objectForKey:@"owner"];
        if ([ownerObject isKindOfClass:[NSString class]]) {
            self.owner = [[Person alloc] initWithLogin:ownerObject];
        } else if (ownerObject != nil) {
            self.owner = [[Person alloc] initWithJSONObject:ownerObject];
        }

        self.repoId = [jsonObject valueForKey:@"id"];

        self.private = [[jsonObject valueForKey:@"private"] boolValue];
        
        self.watchers = [jsonObject valueForKey:@"watchers"];

        self.fork = [[jsonObject valueForKey:@"fork"] boolValue];

        self.forks = [jsonObject valueForKey:@"forks"];

        self.url = [jsonObject valueForKey:@"url"];
        self.createdAt = [[jsonObject valueForKey:@"created_at"] dateForRFC3339DateTimeString];
        self.language = [jsonObject valueForKey:@"language"];
        self.openIssues = [jsonObject valueForKey:@"open_issues"];
        
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
    if (self.owner == nil) {
        return self.name;
    } else {
        return [NSString stringWithFormat:@"%@/%@", self.owner.login, self.name];
    }
}
@end
