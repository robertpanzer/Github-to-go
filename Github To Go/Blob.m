//
//  Blob.m
//  Github To Go
//
//  Created by Robert Panzer on 05.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Blob.h"
#import "NSData+Base64.h"

@implementation Blob

@synthesize absolutePath;
@synthesize url;
@synthesize size;
@synthesize content;

-(id)initWithJSONObject:(NSDictionary*)jsonObject absolutePath:(NSString *)anAbsolutePath {
    self = [super init];
    if (self) {
        absolutePath = [anAbsolutePath retain];
        self.url = [jsonObject objectForKey:@"url"];
        size = [(NSNumber*)[jsonObject objectForKey:@"size"] longValue]; 
        
        NSString* aContent = [jsonObject objectForKey:@"content"];
        if (aContent != nil && ![aContent isMemberOfClass:[NSNull class]]) {
            NSString* encoding = [jsonObject objectForKey:@"encoding"];
            if ([@"utf-8" isEqualToString:encoding]) {
                self.content = aContent;
            } else if ([@"base64" isEqualToString:encoding]) {
//                self.content = aContent;
                self.content = [[[NSString alloc] initWithData:[NSData dataWithBase64EncodedString:aContent] encoding:NSUTF8StringEncoding] autorelease];
            }
        }
    }
    return self;
}

- (NSString *)name {
    return [absolutePath pathComponents].lastObject;
}

- (void)dealloc {
    [absolutePath release];
    [url release];
    [content release];
    [super dealloc];
}
@end
