//
//  PullRequest.m
//  Github To Go
//
//  Created by Robert Panzer on 09.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PullRequest.h"

@implementation PullRequest

@synthesize state;
@synthesize createdAt;
@synthesize creator;
@synthesize title;
@synthesize body;
@synthesize number;
@synthesize selfUrl, issueCommentsUrl, reviewCommentsUrl;
@synthesize merged;
@synthesize repository;

- (id)initWithJSONObject:(NSDictionary*)jsonObject repository:(Repository*)aRepository;
{
    self = [super init];
    if (self) {
        self.repository = aRepository;
        self.number = [jsonObject valueForKey:@"number"];
        self.state = [jsonObject valueForKey:@"state"];
        self.createdAt = [jsonObject valueForKey:@"created_at"];
        self.creator = [[Person alloc] initWithJSONObject:[jsonObject valueForKey:@"user"]];
        self.title = [jsonObject valueForKey:@"title"];
        self.body = [jsonObject valueForKey:@"body"];
        self.selfUrl = [jsonObject valueForKeyPath:@"_links.self.href"];
        self.issueCommentsUrl = [jsonObject valueForKeyPath:@"_links.comments.href"];
        self.reviewCommentsUrl = [jsonObject valueForKeyPath:@"_links.review_comments.href"];
        self.merged = [[jsonObject valueForKey:@"merged"] boolValue];
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
        self.createdAt = [jsonObject valueForKey:@"created_at"];
        self.user = [[Person alloc] initWithJSONObject:[jsonObject valueForKey:@"user"]];
    }
    return self;
}

@end

@implementation PullRequestReviewComment 

- (id)initWithJSONObject:(NSDictionary *)jsonObject
{
    self = [super init];
    if (self) {
        NSLog(@"%@", jsonObject);
    }
    return self;
}

@end