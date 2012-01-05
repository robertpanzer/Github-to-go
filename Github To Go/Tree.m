//
//  Tree.m
//  Github To Go
//
//  Created by Robert Panzer on 05.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Tree.h"

@implementation Tree

@synthesize name;
@synthesize url;
@synthesize subtrees;
@synthesize blobs;

-(id)initWithJSONObject:(NSDictionary*)jsonObject andName:(NSString*)aName {
    self = [super init];
    if (self) {
        self.name = aName;
        self.url = [jsonObject valueForKey:@"url"];
        NSMutableArray* newSubTrees = [[[NSMutableArray alloc] init] autorelease];
        NSMutableArray* newBlobs = [[[NSMutableArray alloc] init] autorelease];
        NSArray* files = [jsonObject valueForKey:@"tree"];
        for (NSDictionary* file in files) {
            if ([@"tree" isEqualToString:[file objectForKey:@"type"]]) {
                Tree* subtree = [[[Tree alloc] initWithJSONObject:file andName:[file objectForKey:@"path"]] autorelease];
                [newSubTrees addObject:subtree]; 
            } else if ([@"blob" isEqualToString:[file objectForKey:@"type"]]) {
                Blob* blob = [[[Blob alloc] initWithJSONObject:file andName:[file objectForKey:@"path"]] autorelease];
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

- (void)dealloc {
    [name release];
    [url release];
    [subtrees release];
    [blobs release];
    [super dealloc];
}
@end
