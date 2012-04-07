//
//  CommitComment.m
//  Github To Go
//
//  Created by Robert Panzer on 06.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CommitComment.h"
#import "NSString+ISO8601Parsing.h"

@implementation CommitComment

@synthesize body, createdAt, identifier, user, position, path;

- (id)initWithJSONObject:(NSDictionary*)jsonObject
{
    self = [super init];
    if (self) {
        self.body = [jsonObject valueForKey:@"body"];
        self.createdAt = [[jsonObject valueForKey:@"created_at"] dateForRFC3339DateTimeString];
        self.identifier = [jsonObject valueForKey:@"id"];
        self.user = [[Person alloc] initWithJSONObject:[jsonObject valueForKey:@"user"]];
        self.path = [jsonObject valueForKey:@"path"];
        id aPosition = [jsonObject valueForKey:@"position"];
        if ([aPosition isKindOfClass:[NSNumber class]]) {
            self.position = [aPosition intValue];
        } else {
            aPosition = [jsonObject valueForKey:@"original_position"];
            if ([aPosition isKindOfClass:[NSNumber class]]) {
                self.position = [aPosition intValue];
            } else {
                self.position = -1;
            }
        }
    }
    return self;
}

@end
