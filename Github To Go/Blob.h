//
//  Blob.h
//  Github To Go
//
//  Created by Robert Panzer on 05.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GitObject.h"

@interface Blob : NSObject <GitObject> {
    NSString* absolutePath;
    NSString* url;
    long size;
    NSString* content;
    NSString* commitSha;
}

@property(readonly) NSString* name;
@property(readonly, strong) NSString* absolutePath;
@property(strong) NSString* url;
@property(strong) NSString* content;
@property(readonly) long size;
@property(readonly) NSString* commitSha;

-(id)initWithJSONObject:(NSDictionary*)jsonObject absolutePath:(NSString*)anAbsolutePath commitSha:(NSString*)aCommitSha;

@end
