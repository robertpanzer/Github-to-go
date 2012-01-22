//
//  Tree.h
//  Github To Go
//
//  Created by Robert Panzer on 05.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Blob.h"
#import "Commit.h"

@interface Tree : NSObject {
    NSString* absolutePath;
    NSString* url;
    
    NSString* commitSha;
    
    NSArray* subtrees;
    NSArray* blobs;
    
}

@property(strong, readonly) NSString* absolutePath;
@property(strong) NSString* url;
@property(strong) NSArray* subtrees;
@property(strong) NSArray* blobs;
@property(readonly) int subtreeCount;
@property(readonly) int blobCount;
@property(readonly) NSString* name;
@property(readonly) NSString* commitSha;



-(id)initWithJSONObject:(NSDictionary*)jsonObject absolutePath:(NSString*)anAbsolutePath commitSha:(NSString*)aCommitSha;

-(Tree*)treeAtIndex:(int)index;
-(Blob*)blobAtIndex:(int)index;

@end
