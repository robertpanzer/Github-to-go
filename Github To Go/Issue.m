//
//  Issue.m
//  Hub To Go
//
//  Created by Robert Panzer on 22.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Issue.h"
#import "NSString+ISO8601Parsing.h"

@implementation Issue

@synthesize state;
@synthesize createdAt;
@synthesize updatedAt;
@synthesize closedAt;
@synthesize creator;
@synthesize title;
@synthesize body;
@synthesize number;
@synthesize repository;
@synthesize htmlUrl;

- (id)initWithJSONObject:(NSDictionary*)jsonObject repository:(Repository *)aRepository
{
    self = [super init];
    if (self) {
        repository = aRepository;
        number = [jsonObject valueForKey:@"number"];
        state = [jsonObject valueForKey:@"state"];
        if ([jsonObject valueForKey:@"created_at"] != [NSNull null]) {
            createdAt = [(NSString*)[jsonObject valueForKey:@"created_at"] dateForRFC3339DateTimeString];
        }
        if ([jsonObject valueForKey:@"updated_at"] != [NSNull null]) {
            updatedAt = [(NSString*)[jsonObject valueForKey:@"updated_at"] dateForRFC3339DateTimeString];
        }
        if ([jsonObject valueForKey:@"closed_at"] != [NSNull null]) {
            closedAt = [(NSString*)[jsonObject valueForKey:@"closed_at"] dateForRFC3339DateTimeString];
        }
        creator = [[Person alloc] initWithJSONObject:[jsonObject valueForKey:@"user"]];
        title = [jsonObject valueForKey:@"title"];
        body = [jsonObject valueForKey:@"body"];
        htmlUrl = [jsonObject valueForKey:@"html_url"];
    }
    return self;
}

@end
