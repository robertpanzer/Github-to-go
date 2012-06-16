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
@synthesize creator;
@synthesize title;
@synthesize body;
@synthesize number;
@synthesize repository;


- (id)initWithJSONObject:(NSDictionary*)jsonObject repository:(Repository *)aRepository
{
    self = [super init];
    if (self) {
        self.repository = aRepository;
        self.number = [jsonObject valueForKey:@"number"];
        self.state = [jsonObject valueForKey:@"state"];
        self.createdAt = [(NSString*)[jsonObject valueForKey:@"created_at"] dateForRFC3339DateTimeString];
        self.updatedAt = [(NSString*)[jsonObject valueForKey:@"updated_at"] dateForRFC3339DateTimeString];
        self.creator = [[Person alloc] initWithJSONObject:[jsonObject valueForKey:@"user"]];
        self.title = [jsonObject valueForKey:@"title"];
        self.body = [jsonObject valueForKey:@"body"];
    }
    return self;
}

@end