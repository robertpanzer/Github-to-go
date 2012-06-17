//
//  GithubEvent.m
//  Github To Go
//
//  Created by Robert Panzer on 09.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GithubEvent.h"
#import "CommitHistoryList.h"
#import "Repository.h"
#import "NSString+ISO8601Parsing.h"

@interface GithubEvent() 

-(void)parseIssueCommentEvent:(NSDictionary*)jsonObject;

-(void)parseWatchEvent:(NSDictionary*)jsonObject;

-(void)parseCreateEvent:(NSDictionary*)jsonObject;

-(void)parseDeleteEvent:(NSDictionary*)jsonObject;

-(void)parseDownloadEvent:(NSDictionary*)jsonObject;

-(void)parseFollowEvent:(NSDictionary*)jsonObject;

-(void)parseIssuesEvent:(NSDictionary*)jsonObject;

-(void)parsePullRequestReviewCommentEvent:(NSDictionary*)jsonObject;

-(void)parseGistEvent:(NSDictionary*)jsonObject;

-(void)parseGollumEvent:(NSDictionary*)jsonObject;
@end



@implementation GithubEvent 

@synthesize text = text_;
@synthesize person = person_;
@synthesize date = date_;
@synthesize repository;
@synthesize primaryKey;

-(id)initWithJSONIssue:(NSDictionary *)jsonObject {
    self = [super init];
    if (self) {
        NSString* type = [jsonObject objectForKey:@"event"];

        self.person = [[Person alloc] initWithJSONObject:[jsonObject valueForKeyPath:@"actor"]];
        self.date = [[jsonObject objectForKey:@"created_at"] dateForRFC3339DateTimeString];
        id commitId = [jsonObject objectForKey:@"commit_id"];
        @try {
            if ([type isEqualToString:@"closed"]) {
                if (commitId == nil || commitId == [NSNull null]) {
                    self.text = [NSString stringWithFormat:@"The issue was closed by %@", self.person.displayname];
                } else {
                    self.text = [NSString stringWithFormat:@"The issue was closed by %@ with commit %@", self.person.displayname, commitId];
                }
            } else if ([type isEqualToString:@"reopened"]) {
                self.text = [NSString stringWithFormat:@"The issue was reopened by %@", self.person.displayname];
            } else if ([type isEqualToString:@"subscribed"]) {
                self.text = [NSString stringWithFormat:@"%@ subscribed to this issue", self.person.displayname];
            } else if ([type isEqualToString:@"merged"]) {
                self.text = [NSString stringWithFormat:@"The issue was merged by %@ with commit %@", self.person.displayname, commitId];
            } else if ([type isEqualToString:@"referenced"]) {
                self.text = [NSString stringWithFormat:@"The issue was referenced by %@ in commit %@", self.person.displayname, commitId];
            } else if ([type isEqualToString:@"mentioned"]) {
                self.text = [NSString stringWithFormat:@"%@ was mentioned in this issue", self.person.displayname];
            } else if ([type isEqualToString:@"assigned"]) {
                self.text = [NSString stringWithFormat:@"The issue was assigned to %@", self.person.displayname];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Exception in GithubEvent.initWithJsonIssue: %@\n%@", exception, exception.callStackSymbols);
            self.text = [NSString stringWithFormat:@"Some %@", type];
        }
    }
    return self;
}

- (id)initWithJSON:(NSDictionary *)jsonObject {
    self = [super init];
    if (self) {
        NSString* type = [jsonObject objectForKey:@"type"];
        
        @try {
            self.person = [[Person alloc] initWithJSONObject:[jsonObject valueForKeyPath:@"actor"]];
            self.date = [[jsonObject objectForKey:@"created_at"] dateForRFC3339DateTimeString];
            self.repository = [[Repository alloc] initFromJSONObject:[jsonObject valueForKey:@"repo"]];
            self.primaryKey = [jsonObject valueForKey:@"id"];
            
            if ([type isEqualToString:@"IssueCommentEvent"]) {
                [self parseIssueCommentEvent:jsonObject];
            } else if ([type isEqualToString:@"WatchEvent"]) {
                [self parseWatchEvent:jsonObject];
            } else if ([type isEqualToString:@"CreateEvent"]) {
                [self parseCreateEvent:jsonObject];
            } else if ([type isEqualToString:@"DeleteEvent"]) {
                [self parseDeleteEvent:jsonObject];
            } else if ([type isEqualToString:@"DownloadEvent"]) {
                [self parseDownloadEvent:jsonObject];
            } else if ([type isEqualToString:@"FollowEvent"]) {
                [self parseFollowEvent:jsonObject];
            } else if ([type isEqualToString:@"IssuesEvent"]) {
                [self parseIssuesEvent:jsonObject];
            } else if ([type isEqualToString:@"PullRequestReviewCommentEvent"]) {
                [self parsePullRequestReviewCommentEvent:jsonObject];
            } else if ([type isEqualToString:@"GistEvent"]) {
                [self parseGistEvent:jsonObject];
            } else if ([type isEqualToString:@"GollumEvent"]) {
                [self parseGollumEvent:jsonObject];
            } else {
                self.text = type;
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Exception in GithubEvent.initWithJson: %@\n%@", exception, exception.callStackSymbols);
            self.text = [NSString stringWithFormat:@"Some %@", type];
        }
        
    }
    return self;
}


-(void)parseIssueCommentEvent:(NSDictionary*)jsonObject {
    NSNumber* issueNumber = [jsonObject valueForKeyPath:@"payload.issue.number"];
    
    self.text = [NSString stringWithFormat:NSLocalizedString(@"%@ commented on issue %d:\n%@", @"IssueCommentEvent"), 
                 self.person.displayname, 
                 issueNumber.intValue,
                 [jsonObject valueForKeyPath:@"payload.comment.body"]];
}



-(void)parseWatchEvent:(NSDictionary *)jsonObject {
    self.text = [NSString stringWithFormat:NSLocalizedString(@"%@ %@ watching %@", @"WatchEvent"),
                 self.person.displayname,
                 [jsonObject valueForKeyPath:@"payload.action"],
                 [jsonObject valueForKeyPath:@"repo.name"] ];
    
}

-(void)parseCreateEvent:(NSDictionary*)jsonObject {
    NSString* refType = [jsonObject valueForKeyPath:@"payload.ref_type"];
    if (![@"repository" isEqualToString:refType]) {
        self.text = [NSString stringWithFormat:NSLocalizedString(@"%@ has created %@ %@", @"CreateEvent"),
                     self.person.displayname,
                     refType,
                     [jsonObject valueForKeyPath:@"payload.ref"] ];
    } else {
        self.text = [NSString stringWithFormat:NSLocalizedString(@"%@ has created %@ %@", @"CreateEvent"),
                     self.person.displayname,
                     refType,
                     [jsonObject valueForKeyPath:@"repo.name"]];
    }
}

-(void)parseDeleteEvent:(NSDictionary*)jsonObject {
    self.text = [NSString stringWithFormat:NSLocalizedString(@"%@ has deleted %@ %@", @"DeleteEvent"),
                 self.person.displayname,
                 [jsonObject valueForKeyPath:@"payload.ref_type"],
                 [jsonObject valueForKeyPath:@"payload.ref"] ];
}

-(void)parseDownloadEvent:(NSDictionary*)jsonObject {
    self.text = [NSString stringWithFormat:NSLocalizedString(@"%@ has created download %@", @"DownloadEvent"),
                 self.person.displayname,
                 [jsonObject valueForKeyPath:@"payload.download.name"] ];
}

-(void)parseFollowEvent:(NSDictionary*)jsonObject {
    Person *followedPerson = [[Person alloc] initWithJSONObject:[jsonObject valueForKeyPath:@"payload.target"]];
    self.text = [NSString stringWithFormat:NSLocalizedString(@"%@ is following %@", @"FollowEvent"),
                 self.person.displayname,
                 followedPerson.displayname ];
}

-(void)parseIssuesEvent:(NSDictionary*)jsonObject {
    self.text = [NSString stringWithFormat:NSLocalizedString(@"%@ %@ issue %@:\n%@", @"IssueEvent"),
                 self.person.displayname,
                 [jsonObject valueForKeyPath:@"payload.action"],
                 [jsonObject valueForKeyPath:@"payload.issue.number"],
                 [jsonObject valueForKeyPath:@"payload.issue.title"] ];
}

-(void)parsePullRequestReviewCommentEvent:(NSDictionary*)jsonObject {
    self.text = [NSString stringWithFormat:NSLocalizedString(@"%@ commented on pull request:\n%@", @"PullRequestReviewEvent"),
                 self.person.displayname,
                 [jsonObject valueForKeyPath:@"payload.comment.body"]];
}

-(void)parseGistEvent:(NSDictionary*)jsonObject {
    self.text = [NSString stringWithFormat:NSLocalizedString(@"%@ %@d gist %@:\n%@", @"GistEvent"),
                 self.person.displayname,
                 [jsonObject valueForKeyPath:@"payload.action"],
                 [jsonObject valueForKeyPath:@"payload.gist.id"],
                 [jsonObject valueForKeyPath:@"payload.gist.description"]
                 ];
}

-(void)parseGollumEvent:(NSDictionary*)jsonObject {
    NSMutableString * newText = [NSMutableString stringWithString:self.person.displayname];
    BOOL first = YES;
    for (NSDictionary *gollumAction in [jsonObject valueForKeyPath:@"payload.pages"]) {
        if (first) {
            first = NO;
            [newText appendString:@" "];
        } else {
            [newText appendString:@", "];
        }
        NSString *action = [NSString stringWithFormat:NSLocalizedString(@"%@ page %@", @"GollumEvent"), 
                            [gollumAction valueForKey:@"action"],
                            [gollumAction valueForKey:@"page_name"]
                            ];
        [newText appendString:action];
        
    }
    self.text = newText;
}

@end

@implementation PullRequestEvent 

@synthesize pullRequest;

-(id)initWithJSON:(NSDictionary *)jsonObject {
    self = [super initWithJSON:jsonObject];
    if (self) {
        self.pullRequest = [[PullRequest alloc] initWithJSONObject:[jsonObject valueForKeyPath:@"payload.pull_request"]  repository:nil];
        self.pullRequest.repository = self.repository;
        NSNumber* pullRequestNumber = [jsonObject valueForKeyPath:@"payload.pull_request.number"];
        NSString* action = [jsonObject valueForKeyPath:@"payload.action"];
        self.text = [NSString stringWithFormat:NSLocalizedString(@"%@ %@ pull request %d\n%@", @"PullRequestEvent"), 
                     self.person.displayname, 
                     action,
                     pullRequestNumber.intValue,
                     [jsonObject valueForKeyPath:@"payload.pull_request.title"]];

    }
    return self;
}

@end

@implementation PushEvent

@synthesize commits;

-(id)initWithJSON:(NSDictionary *)jsonObject {
    self = [super initWithJSON:jsonObject];
    if (self) {
        
        NSNumber* commitCount = [jsonObject valueForKeyPath:@"payload.size"];
        NSArray* commitArray = [jsonObject valueForKeyPath:@"payload.commits"];

        self.commits = [[CommitHistoryList alloc] init];
        for (NSDictionary* commitJsonObject in commitArray) {
            Commit* commit = [[Commit alloc] initWithJSONObjectFromPushEvent:commitJsonObject committer:self.person];
            commit.committedDate = self.date;
            [self.commits addCommit:commit];
        }
        
        if (commitCount.intValue == 1) {
            NSDictionary* commit = [commitArray objectAtIndex:0];
            NSString* message = [commit valueForKeyPath:@"message"];
            if (message == nil) {
                self.text = [NSString stringWithFormat:NSLocalizedString(@"%@ has pushed a commit", @"PushEvent"), 
                             self.person.displayname];
            } else {
                self.text = [NSString stringWithFormat:NSLocalizedString(@"%@ has pushed a commit:\n%@", @"PushEvent"), 
                             self.person.displayname, 
                             [commit valueForKeyPath:@"message"]];
            }        
        } else {
            self.text = [NSString stringWithFormat:NSLocalizedString(@"%@ has pushed %d commits", @"PushEvent"), 
                         self.person.displayname, 
                         commitCount.intValue];
        }


    }
    return self;
}


@end



@implementation CreateRepositoryEvent 

@end

@implementation ForkEvent

-(id)initWithJSON:(NSDictionary *)jsonObject {
    self = [super initWithJSON:jsonObject];
    if (self != nil) {
        self.repository = [[Repository alloc] initFromJSONObject:[jsonObject valueForKeyPath:@"payload.forkee"]];
        self.text = [NSString stringWithFormat:NSLocalizedString(@"%@ has forked repository %@ to %@", @"ForkEvent"),
                     self.person.displayname,
                     [jsonObject valueForKeyPath:@"repo.name"],
                     self.repository.fullName];
    }
    
    return self;
}

@end

@implementation CommitCommentEvent 

@synthesize commitSha;

-(id)initWithJSON:(NSDictionary *)jsonObject {
    self = [super initWithJSON:jsonObject];
    if (self != nil) {
        self.repository = [[Repository alloc] initFromJSONObject:[jsonObject valueForKeyPath:@"repo"]];
        self.text = [NSString stringWithFormat:NSLocalizedString(@"%@ commented on commit %@:\n%@", @"CommitCommentEvent"),
                     self.person.displayname,
                     [jsonObject valueForKeyPath:@"payload.comment.commit_id"],
                     [jsonObject valueForKeyPath:@"payload.comment.body"] ];
        self.commitSha = [jsonObject valueForKeyPath:@"payload.comment.commit_id"];
    }
    
    return self;
}


@end

@implementation PullRequestReviewCommentEvent

@synthesize commitSha;

-(id)initWithJSON:(NSDictionary *)jsonObject {
    self = [super initWithJSON:jsonObject];
    if (self != nil) {
        self.repository = [[Repository alloc] initFromJSONObject:[jsonObject valueForKeyPath:@"repo"]];
        self.text = [NSString stringWithFormat:NSLocalizedString(@"%@ commented on commit %@ of pull request:\n%@", @"PullRequestReviewCommentEvent"),
                     self.person.displayname,
                     [jsonObject valueForKeyPath:@"payload.comment.commit_id"],
                     [jsonObject valueForKeyPath:@"payload.comment.body"] ];
        self.commitSha = [jsonObject valueForKeyPath:@"payload.comment.commit_id"];
    }
    
    return self;
}

@end

@implementation EventFactory
    
+(GithubEvent*) createEventFromJsonObject:(NSDictionary*)jsonObject {
    NSString* type = [jsonObject objectForKey:@"type"];
    if (type != nil) {
        @try {
            if ([type isEqualToString:@"PushEvent"]) {
                return [[PushEvent alloc] initWithJSON:jsonObject];
            } else if ([type isEqualToString:@"IssueCommentEvent"]) {
                return [[GithubEvent alloc] initWithJSON:jsonObject];
            } else if ([type isEqualToString:@"PullRequestEvent"]) {
                return [[PullRequestEvent alloc] initWithJSON:jsonObject];
            } else if ([type isEqualToString:@"ForkEvent"]) {
                return [[ForkEvent alloc] initWithJSON:jsonObject];
            } else if ([type isEqualToString:@"CommitCommentEvent"]) {
                return [[CommitCommentEvent alloc] initWithJSON:jsonObject];
            } else if ([type isEqualToString:@"WatchEvent"]) {
                return [[GithubEvent alloc] initWithJSON:jsonObject];
            } else if ([type isEqualToString:@"CreateEvent"]) {
                NSString* refType = [jsonObject valueForKeyPath:@"payload.ref_type"];
                if ([@"repository" isEqualToString:refType]) {
                    return [[CreateRepositoryEvent alloc] initWithJSON:jsonObject];
                } else {
                    return [[GithubEvent alloc] initWithJSON:jsonObject];
                }
            } else if ([type isEqualToString:@"DeleteEvent"]) {
                return [[GithubEvent alloc] initWithJSON:jsonObject];
            } else if ([type isEqualToString:@"DownloadEvent"]) {
                return [[GithubEvent alloc] initWithJSON:jsonObject];
            } else if ([type isEqualToString:@"FollowEvent"]) {
                return [[GithubEvent alloc] initWithJSON:jsonObject];
            } else if ([type isEqualToString:@"IssuesEvent"]) {
                return [[GithubEvent alloc] initWithJSON:jsonObject];
            } else if ([type isEqualToString:@"PullRequestReviewCommentEvent"]) {
                return [[PullRequestReviewCommentEvent alloc] initWithJSON:jsonObject];
            } else {
                return [[GithubEvent alloc] initWithJSON:jsonObject];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Exception in GithubEvent.initWithJson: %@\n%@", exception, exception.callStackSymbols);
            return nil;
        }
    }
    NSString *event = [jsonObject objectForKey:@"event"];
    if (event != nil) {
        @try {
            if ([event isEqualToString:@"closed"]
                || [event isEqualToString:@"reopened"]
                || [event isEqualToString:@"subscribed"]
                || [event isEqualToString:@"merged"]
                || [event isEqualToString:@"referenced"]
                || [event isEqualToString:@"mentioned"]
                || [event isEqualToString:@"assigned"]
                ) {
                return [[GithubEvent alloc] initWithJSONIssue:jsonObject];

            }
        }
        @catch (NSException *exception) {
            NSLog(@"Exception in GithubEvent.initWithJson: %@\n%@", exception, exception.callStackSymbols);
            return nil;
        }
    }
    return nil;
}

@end
