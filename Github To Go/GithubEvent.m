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
    
    self.text = [NSString stringWithFormat:@"%@ commented on issue %d:\n%@", 
                 self.person.displayname, 
                 issueNumber.intValue,
                 [jsonObject valueForKeyPath:@"payload.comment.body"]];
}



-(void)parseWatchEvent:(NSDictionary *)jsonObject {
    self.text = [NSString stringWithFormat:@"%@ %@ watching %@",
                 self.person.displayname,
                 [jsonObject valueForKeyPath:@"payload.action"],
                 [jsonObject valueForKeyPath:@"repo.name"] ];
    
}

-(void)parseCreateEvent:(NSDictionary*)jsonObject {
    NSString* refType = [jsonObject valueForKeyPath:@"payload.ref_type"];
    if (![@"repository" isEqualToString:refType]) {
        self.text = [NSString stringWithFormat:@"%@ has created %@ %@",
                     self.person.displayname,
                     refType,
                     [jsonObject valueForKeyPath:@"payload.ref"] ];
    } else {
        self.text = [NSString stringWithFormat:@"%@ has created %@ %@",
                     self.person.displayname,
                     refType,
                     [jsonObject valueForKeyPath:@"repo.name"]];
    }
}

-(void)parseDeleteEvent:(NSDictionary*)jsonObject {
    self.text = [NSString stringWithFormat:@"%@ has deleted %@ %@",
                 self.person.displayname,
                 [jsonObject valueForKeyPath:@"payload.ref_type"],
                 [jsonObject valueForKeyPath:@"payload.ref"] ];
}

-(void)parseDownloadEvent:(NSDictionary*)jsonObject {
    self.text = [NSString stringWithFormat:@"%@ has created download %@",
                 self.person.displayname,
                 [jsonObject valueForKeyPath:@"payload.download.name"] ];
}

-(void)parseFollowEvent:(NSDictionary*)jsonObject {
    Person *followedPerson = [[Person alloc] initWithJSONObject:[jsonObject valueForKeyPath:@"payload.target"]];
    self.text = [NSString stringWithFormat:@"%@ is following %@",
                 self.person.displayname,
                 followedPerson.displayname ];
}

-(void)parseIssuesEvent:(NSDictionary*)jsonObject {
    self.text = [NSString stringWithFormat:@"%@ %@ issue %@:\n%@",
                 self.person.displayname,
                 [jsonObject valueForKeyPath:@"payload.action"],
                 [jsonObject valueForKeyPath:@"payload.issue.number"],
                 [jsonObject valueForKeyPath:@"payload.issue.title"] ];
}

-(void)parsePullRequestReviewCommentEvent:(NSDictionary*)jsonObject {
    self.text = [NSString stringWithFormat:@"%@ commented on pull request:\n%@",
                 self.person.displayname,
                 [jsonObject valueForKeyPath:@"payload.comment.body"]];
}

-(void)parseGistEvent:(NSDictionary*)jsonObject {
    self.text = [NSString stringWithFormat:@"%@ %@d gist %@:\n%@",
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
        NSString *action = [NSString stringWithFormat:@"%@ page %@", 
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
        self.text = [NSString stringWithFormat:@"%@ %@ pull request %d\n%@", 
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
                self.text = [NSString stringWithFormat:@"%@ has pushed a commit", 
                             self.person.displayname];
            } else {
                self.text = [NSString stringWithFormat:@"%@ has pushed a commit:\n%@", 
                             self.person.displayname, 
                             [commit valueForKeyPath:@"message"]];
            }        
        } else {
            self.text = [NSString stringWithFormat:@"%@ has pushed %d commits", 
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
        self.text = [NSString stringWithFormat:@"%@ has forked repository %@ to %@",
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
        self.text = [NSString stringWithFormat:@"%@ commented on commit %@:\n%@",
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
        self.text = [NSString stringWithFormat:@"%@ commented on commit %@ of pull request:\n%@",
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

@end
