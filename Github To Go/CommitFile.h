//
//  CommitFile.h
//  Github To Go
//
//  Created by Robert Panzer on 14.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Commit.h"

@interface CommitFile : NSObject {
    NSString* status;
    int additions;
    int deletions;
    int changes;
    NSString* patch;
    NSString* blobUrl;
    NSString* fileName;
    NSString* blobSha;
    Commit* commit;
}

@property(strong) NSString* status;
@property(strong) NSString* patch;
@property(strong) NSString* blobUrl;
@property(strong) NSString* fileName;
@property(strong) NSString* blobSha;
@property(weak) Commit* commit;


- (id)initWithJSONObject:(NSDictionary*)jsonObject commit:(Commit*)aCommit;

- (void)loadFile;
@end
