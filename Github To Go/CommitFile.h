//
//  CommitFile.h
//  Github To Go
//
//  Created by Robert Panzer on 14.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Commit.h"

@interface CommitFile : NSObject 

@property(strong) NSString* status;
@property(strong) NSString* patch;
@property(strong) NSString* blobUrl;
@property(strong) NSString* fileName;
@property(strong) NSString* blobSha;
@property(strong) NSString* rawUrl;
@property(weak) Commit* commit;
@property int additions;
@property int deletions;
@property int changes;
@property (strong) NSMutableDictionary* linesOfOldFile;
@property (strong) NSMutableDictionary* linesOfNewFile;
@property int largestOldLineNo;
@property int largestNewLineNo;



- (id)initWithJSONObject:(NSDictionary*)jsonObject commit:(Commit*)aCommit;

- (void)loadFile;
@end
