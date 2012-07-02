//
//  Blob.h
//  Github To Go
//
//  Created by Robert Panzer on 05.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GitObject.h"

@interface Blob : NSObject <GitObject>

@property(readonly) NSString* name;
@property(readonly, strong, nonatomic) NSString* absolutePath;
@property(strong, nonatomic) NSString* url;
@property(strong, nonatomic) id content;
@property(strong, nonatomic) NSData *rawContent;
@property(readonly, nonatomic) long size;
@property(readonly, strong, nonatomic) NSString* commitSha;
@property(readonly, strong) NSString* htmlUrl;

-(id)initWithJSONObject:(NSDictionary*)jsonObject absolutePath:(NSString*)anAbsolutePath commitSha:(NSString*)aCommitSha;

-(id)initWithRawData:(NSString*)rawData absolutePath:(NSString *)anAbsolutePath commitSha:(NSString *)aCommitSha;

-(id)initWithData:(NSData*)rawData absolutePath:(NSString *)anAbsolutePath commitSha:(NSString *)aCommitSha;

@end
