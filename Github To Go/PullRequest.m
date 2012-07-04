//
//  PullRequest.m
//  Github To Go
//
//  Created by Robert Panzer on 09.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PullRequest.h"
#import "NSString+ISO8601Parsing.h"

@implementation PullRequest

@synthesize state;
@synthesize createdAt;
@synthesize updatedAt;
@synthesize creator;
@synthesize title;
@synthesize body;
@synthesize number;
@synthesize selfUrl, issueCommentsUrl, reviewCommentsUrl;
@synthesize merged;
@synthesize repository;
@synthesize htmlUrl;

- (id)initWithJSONObject:(NSDictionary*)jsonObject repository:(Repository*)aRepository;
{
    self = [super init];
    if (self) {
        repository = aRepository;
        number = [jsonObject valueForKey:@"number"];
        state = [jsonObject valueForKey:@"state"];
        createdAt = [(NSString*)[jsonObject valueForKey:@"created_at"] dateForRFC3339DateTimeString];
        updatedAt = [(NSString*)[jsonObject valueForKey:@"updated_at"] dateForRFC3339DateTimeString];
        creator = [[Person alloc] initWithJSONObject:[jsonObject valueForKey:@"user"]];
        title = [jsonObject valueForKey:@"title"];
        body = [jsonObject valueForKey:@"body"];
        selfUrl = [jsonObject valueForKeyPath:@"_links.self.href"];
        issueCommentsUrl = [jsonObject valueForKeyPath:@"_links.comments.href"];
        reviewCommentsUrl = [jsonObject valueForKeyPath:@"_links.review_comments.href"];
        merged = [[jsonObject valueForKey:@"merged"] boolValue];
        htmlUrl = [jsonObject valueForKey:@"html_url"];
    }
    return self;
}

@end


@implementation PullRequestIssueComment
    
@synthesize body, createdAt, user;

- (id)initWithJSONObject:(NSDictionary*)jsonObject
{
    self = [super init];
    if (self) {
        self.body = [jsonObject valueForKey:@"body"];
        self.createdAt = [(NSString*)[jsonObject valueForKey:@"created_at"] dateForRFC3339DateTimeString];
        self.user = [[Person alloc] initWithJSONObject:[jsonObject valueForKey:@"user"]];
    }
    return self;
}

@end
