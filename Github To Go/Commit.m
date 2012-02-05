//
//  Commit.m
//  Github To Go
//
//  Created by Robert Panzer on 04.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CommitFile.h"
#import "Commit.h"
#import "GitObject.h"
#import "NetworkProxy.h"
#import "Tree.h"
#import <Foundation/Foundation.h>

@interface Commit() 

-(void)loadObjectWithAbsolutePath:(NSArray*)pathElements fromTree:(Tree*)tree;

@end

@implementation Commit

@synthesize treeUrl;
@synthesize commitUrl;
@synthesize author;
@synthesize committer;
@synthesize message;
@synthesize parentUrls;
@synthesize parentCommitShas;
@synthesize changedFiles;
@synthesize sha;
@synthesize deletions;
@synthesize additions;
@synthesize total;
@synthesize committedDate;
@synthesize authoredDate;
@synthesize repository;

-(id)initMinimalDataWithJSONObject:(NSDictionary *)jsonObject repository:(Repository *)aRepository {
    self = [super init];
    if (self) {
        self.repository = aRepository;
        self.commitUrl = [jsonObject objectForKey:@"url"];
        self.sha = [jsonObject objectForKey:@"sha"];

        NSDictionary* jsonCommit = [jsonObject objectForKey:@"commit"];
        
        NSDictionary* tree = [jsonCommit objectForKey:@"tree"];
        self.treeUrl = [tree objectForKey:@"url"];
        
        id jsonCommitAuthor = [jsonCommit valueForKey:@"author"];
        id jsonAuthor = [jsonObject valueForKey:@"author"];
        if (![jsonCommitAuthor isEqual:[NSNull null]]) {
            self.author = [[[Person alloc] initWithJSONObject:jsonCommitAuthor JSONObject:jsonAuthor] autorelease];
        }
        id jsonCommitCommitter = [jsonCommit valueForKey:@"committer"];
        id jsonCommitter = [jsonObject valueForKey:@"committer"];
        if (![jsonCommitCommitter isEqual:[NSNull null]]) {
            self.committer = [[[Person alloc] initWithJSONObject:jsonCommitCommitter JSONObject:jsonCommitter] autorelease];
            self.committedDate = [jsonCommitCommitter objectForKey:@"date"];
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

-(id)initWithJSONObject:(NSDictionary*)jsonObject repository:(Repository *)aRepository {
    self = [super init];
    if (self) {
        self.repository = aRepository;
        self.commitUrl = [jsonObject objectForKey:@"url"];
        self.sha = [jsonObject objectForKey:@"sha"];
        
        NSDictionary* jsonCommit = [jsonObject objectForKey:@"commit"];

        NSDictionary* tree = [jsonCommit objectForKey:@"tree"];
        self.treeUrl = [tree objectForKey:@"url"];

        id jsonAuthor = [jsonObject valueForKey:@"author"];
        id jsonCommitAuthor = [jsonCommit valueForKey:@"author"];
        if (jsonCommitAuthor != [NSNull null]) {
            self.author = [[[Person alloc] initWithJSONObject:jsonCommitAuthor JSONObject:jsonAuthor] autorelease];
            self.authoredDate = [jsonCommitAuthor objectForKey:@"date"];
        }
        id jsonCommitter = [jsonObject valueForKey:@"committer"];
        id jsonCommitCommitter = [jsonCommit valueForKey:@"committer"];
        if (jsonCommitCommitter != [NSNull null]) {
            self.committer = [[[Person alloc] initWithJSONObject:jsonCommitCommitter JSONObject:jsonCommitter] autorelease];
            self.committedDate = [jsonCommitCommitter objectForKey:@"date"];
        }
        
        self.message = [jsonCommit objectForKey:@"message"];
        
        NSArray* files = [jsonObject objectForKey:@"files"];
        NSMutableArray* newChangedFiles = [[[NSMutableArray alloc] init] autorelease];
        for (NSDictionary* file in files) {
            CommitFile* changedFile = [[[CommitFile alloc] initWithJSONObject:file commit:self] autorelease];
            [newChangedFiles addObject:changedFile];
        }
        self.changedFiles = newChangedFiles;

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


- (BOOL)matchesString:(NSString *)searchString {
    if (author.name != nil && [author.name rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return YES;
    }
    if (author.email != nil && [author.email rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return YES;
    }
    if (author.login != nil && [author.login rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return YES;
    }
    if (committer.name != nil && [committer.name rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return YES;
    }
    if (committer.email != nil && [committer.email rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return YES;
    }
    if (committer.login != nil && [committer.login rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return YES;
    }
    if (message != nil && [message rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return YES;
    }
    
    return NO;
}

- (void)loadObjectWithAbsolutePath:(NSString*)absolutePath {
    NSArray* pathElements = [absolutePath pathComponents];
    [[NetworkProxy sharedInstance] loadStringFromURL:treeUrl block:^(int statusCode, NSDictionary* headerFields, id data) {
        if (statusCode == 200) {
            Tree* rootTree = [[[Tree alloc] initWithJSONObject:data absolutePath:@"" commitSha:self.sha] autorelease];
            [self loadObjectWithAbsolutePath:pathElements fromTree:rootTree];
        }
    }];
}

-(void)loadObjectWithAbsolutePath:(NSArray *)pathElements fromTree:(Tree *)tree {
    for (Tree* subtree in tree.subtrees) {
        if ([[pathElements objectAtIndex:0] isEqual:subtree.name]) {
            [[NetworkProxy sharedInstance] loadStringFromURL:subtree.url block:^(int statusCode, NSDictionary* headerFields, id data) {
                if (statusCode == 200) {
//                    NSString* absolutePath = [tree.absolutePath stringByAppendingPathComponent:subtree.name];
                    Tree* fullSubTree = [[[Tree alloc] initWithJSONObject:data absolutePath:subtree.absolutePath commitSha:self.sha] autorelease];
                    [self loadObjectWithAbsolutePath:[pathElements subarrayWithRange:NSMakeRange(1, pathElements.count - 1)]  fromTree:fullSubTree];
                }
            }];
        }
    }
    for (Blob* blob in tree.blobs) {
        if ([[pathElements objectAtIndex:0] isEqual:blob.name]) {
            [[NetworkProxy sharedInstance] loadStringFromURL:blob.url block:^(int statusCode, NSDictionary* headerFields, id data) {
                if (statusCode == 200) {
                    Blob* fullBlob = [[[Blob alloc] initWithJSONObject:data absolutePath:blob.absolutePath commitSha:blob.commitSha] autorelease];
                    NSLog(@"Blob: %@", fullBlob);
                }
            }];
            
        }
    }
}

- (void)dealloc {
    [treeUrl release];
    [commitUrl release];
    [author release];
    [committer release];
    [message release];
    [parentUrls release];
    [parentCommitShas release];
    [changedFiles release];
    [sha release];
    [committedDate release];
    [authoredDate release];
    
    
    [super dealloc];
}
@end
