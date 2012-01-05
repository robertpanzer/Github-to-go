//
//  Tree.h
//  Github To Go
//
//  Created by Robert Panzer on 05.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Blob.h"

@interface Tree : NSObject {
    NSString* name;
    NSString* url;
    
    NSArray* subtrees;
    NSArray* blobs;
}

@property(strong) NSString* name;
@property(strong) NSString* url;
@property(strong) NSArray* subtrees;
@property(strong) NSArray* blobs;
@property(readonly) int subtreeCount;
@property(readonly) int blobCount;



-(id)initWithJSONObject:(NSDictionary*)jsonObject andName:(NSString*)aName;

-(Tree*)treeAtIndex:(int)index;
-(Blob*)blobAtIndex:(int)index;

@end
