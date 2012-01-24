//
//  Tree.m
//  Github To Go
//
//  Created by Robert Panzer on 05.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Tree.h"

@implementation Tree

@synthesize absolutePath;
@synthesize url;
@synthesize subtrees;
@synthesize blobs;
@synthesize commitSha;

-(id)initWithJSONObject:(NSDictionary*)jsonObject absolutePath:(NSString*)anAbsolutePath commitSha:(NSString *)aCommitSha {
    self = [super init];
    if (self) {
        absolutePath = [anAbsolutePath retain];
        commitSha = [aCommitSha retain];
        NSLog(@"Absolute path: %@", absolutePath);
        self.url = [jsonObject valueForKey:@"url"];
        NSMutableArray* newSubTrees = [[[NSMutableArray alloc] init] autorelease];
        NSMutableArray* newBlobs = [[[NSMutableArray alloc] init] autorelease];
        NSArray* files = [jsonObject valueForKey:@"tree"];
        for (NSDictionary* file in files) {
            if ([@"tree" isEqualToString:[file objectForKey:@"type"]]) {
                NSString* subTreePath = [absolutePath stringByAppendingPathComponent:[file objectForKey:@"path"]];
                Tree* subtree = [[[Tree alloc] initWithJSONObject:file absolutePath:subTreePath commitSha:self.commitSha] autorelease];
                [newSubTrees addObject:subtree]; 
            } else if ([@"blob" isEqualToString:[file objectForKey:@"type"]]) {
                NSString* filename = [file objectForKey:@"path"];
                Blob* blob = [[[Blob alloc] initWithJSONObject:file absolutePath:[absolutePath stringByAppendingPathComponent:filename] commitSha:commitSha] autorelease];
                [newBlobs addObject:blob];
            }
        }
        self.subtrees = newSubTrees;
        self.blobs = newBlobs;
    }
    return self;
}

-(int)subtreeCount {
    return subtrees.count;
}

-(int)blobCount {
    return blobs.count;
}

-(Tree*)treeAtIndex:(int)index {
    id ret = [subtrees objectAtIndex:index]; 
    return ret;
}

-(Blob*)blobAtIndex:(int)index {
    id ret = [blobs objectAtIndex:index]; 
    return ret;
}

-(NSString*)name {
    return [absolutePath pathComponents].lastObject;
}

- (void)dealloc {
    [absolutePath release];
    [url release];
    [subtrees release];
    [blobs release];
    [commitSha release];
    [super dealloc];
}
@end
