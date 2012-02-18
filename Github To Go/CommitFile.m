//
//  CommitFile.m
//  Github To Go
//
//  Created by Robert Panzer on 14.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CommitFile.h"

@implementation CommitFile 

@synthesize status;
@synthesize patch;
@synthesize blobUrl;
@synthesize fileName;
@synthesize commit;
@synthesize blobSha;


- (id)initWithJSONObject:(NSDictionary*)jsonObject commit:(Commit *)aCommit{
    self = [super init];
    if (self) {
        self.commit = aCommit;
        self.status = [jsonObject objectForKey:@"status"];
        self.patch = [jsonObject objectForKey:@"patch"];
        self.blobUrl = [jsonObject objectForKey:@"blob_url"];
        self.fileName = [jsonObject objectForKey:@"filename"];
        self.blobSha = [jsonObject objectForKey:@"sha"];
        additions = [(NSNumber*)[jsonObject objectForKey:@"additions"] intValue];
        deletions = [(NSNumber*)[jsonObject objectForKey:@"deletions"] intValue];
        changes = [(NSNumber*)[jsonObject objectForKey:@"changes"] intValue];
    }
    return self;
}

-(void)loadFile {
    [commit loadObjectWithAbsolutePath:self.fileName];
}



@end
