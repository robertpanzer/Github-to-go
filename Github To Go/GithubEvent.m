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

@interface GithubEvent() 

-(void)parseCommitComment:(NSDictionary*)jsonObject;

-(void)parseIssueCommentEvent:(NSDictionary*)jsonObject;

-(void)parsePullRequestEvent:(NSDictionary*)jsonObject;

-(void)parseForkEvent:(NSDictionary*)jsonObject;

-(void)parseWatchEvent:(NSDictionary*)jsonObject;

-(void)parseCreateEvent:(NSDictionary*)jsonObject;

-(void)parseDeleteEvent:(NSDictionary*)jsonObject;

-(void)parseDownloadEvent:(NSDictionary*)jsonObject;

-(void)parseFollowEvent:(NSDictionary*)jsonObject;

-(void)parseIssuesEvent:(NSDictionary*)jsonObject;

-(void)parsePullRequestReviewCommentEvent:(NSDictionary*)jsonObject;
@end



@implementation GithubEvent 

@synthesize text = text_;
@synthesize person = person_;
@synthesize date = date_;

- (id)initWithJSON:(NSDictionary *)jsonObject {
    self = [super init];
    if (self) {
        NSString* type = [jsonObject objectForKey:@"type"];
        
        @try {
            self.person = [[Person alloc] initWithJSONObject:[jsonObject valueForKeyPath:@"actor"]];
            self.date = [jsonObject objectForKey:@"created_at"];
            NSLog(@"%@", type);
            if ([type isEqualToString:@"IssueCommentEvent"]) {
                [self parseIssueCommentEvent:jsonObject];
            } else if ([type isEqualToString:@"PullRequestEvent"]) {
                [self parsePullRequestEvent:jsonObject];
            } else if ([type isEqualToString:@"ForkEvent"]) {
                [self parseForkEvent:jsonObject];
            } else if ([type isEqualToString:@"CommitCommentEvent"]) {
                [self parseCommitComment:jsonObject];
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

-(void)parsePullRequestEvent:(NSDictionary*)jsonObject {
    NSNumber* pullRequestNumber = [jsonObject valueForKeyPath:@"payload.pull_request.number"];
    NSString* action = [jsonObject valueForKeyPath:@"payload.action"];
    self.text = [NSString stringWithFormat:@"%@ %@ pull request %d\n%@", 
                 self.person.displayname, 
                 action,
                 pullRequestNumber.intValue,
                 [jsonObject valueForKeyPath:@"payload.pull_request.title"]];
}

-(void)parseForkEvent:(NSDictionary*)jsonObject {
    self.text = [NSString stringWithFormat:@"%@ has forked repository %@",
                 self.person.displayname,
                 [jsonObject valueForKeyPath:@"payload.forkee.name"]];
}

-(void)parseCommitComment:(NSDictionary *)jsonObject {
    self.text = [NSString stringWithFormat:@"%@ commented on commit %@:\n%@",
                 self.person.displayname,
                 [jsonObject valueForKeyPath:@"payload.comment.commit_id"],
                 [jsonObject valueForKeyPath:@"payload.comment.body"] ];
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
        self.text = [NSString stringWithFormat:@"%@ has created %@",
                     self.person.displayname,
                     refType];
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
    self.text = [NSString stringWithFormat:@"%@ is following %@",
                 self.person.displayname,
                 [jsonObject valueForKeyPath:@"payload.object.login"] ];
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

@end


@implementation PushEvent

@synthesize commits;

-(id)initWithJSON:(NSDictionary *)jsonObject {
    self = [super init];
    if (self) {
        self.person = [[Person alloc] initWithJSONObject:[jsonObject valueForKeyPath:@"actor"]];
        self.date = [jsonObject objectForKey:@"created_at"];

        NSNumber* commitCount = [jsonObject valueForKeyPath:@"payload.size"];
        NSArray* commitArray = [jsonObject valueForKeyPath:@"payload.commits"];

        self.commits = [[CommitHistoryList alloc] init];
        for (NSDictionary* commitJsonObject in commitArray) {
            Commit* commit = [[Commit alloc] initWithJSONObjectFromPushEvent:commitJsonObject];
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

@implementation EventFactory
    
+(GithubEvent*) createEventFromJsonObject:(NSDictionary*)jsonObject {
    NSString* type = [jsonObject objectForKey:@"type"];
    
    NSLog(@"%@", type);
    if ([type isEqualToString:@"PushEvent"]) {
        return [[PushEvent alloc] initWithJSON:jsonObject];
    } else if ([type isEqualToString:@"IssueCommentEvent"]) {
        return [[GithubEvent alloc] initWithJSON:jsonObject];
    } else if ([type isEqualToString:@"PullRequestEvent"]) {
        return [[GithubEvent alloc] initWithJSON:jsonObject];
    } else if ([type isEqualToString:@"ForkEvent"]) {
        return [[GithubEvent alloc] initWithJSON:jsonObject];
    } else if ([type isEqualToString:@"CommitCommentEvent"]) {
        return [[GithubEvent alloc] initWithJSON:jsonObject];
    } else if ([type isEqualToString:@"WatchEvent"]) {
        return [[GithubEvent alloc] initWithJSON:jsonObject];
    } else if ([type isEqualToString:@"CreateEvent"]) {
        return [[GithubEvent alloc] initWithJSON:jsonObject];
    } else if ([type isEqualToString:@"DeleteEvent"]) {
        return [[GithubEvent alloc] initWithJSON:jsonObject];
    } else if ([type isEqualToString:@"DownloadEvent"]) {
        return [[GithubEvent alloc] initWithJSON:jsonObject];
    } else if ([type isEqualToString:@"FollowEvent"]) {
        return [[GithubEvent alloc] initWithJSON:jsonObject];
    } else if ([type isEqualToString:@"IssuesEvent"]) {
        return [[GithubEvent alloc] initWithJSON:jsonObject];
    } else if ([type isEqualToString:@"PullRequestReviewCommentEvent"]) {
        return [[GithubEvent alloc] initWithJSON:jsonObject];
    } else {
        return [[GithubEvent alloc] initWithJSON:jsonObject];
    }
    
}

@end
