//
//  GithubEvent.m
//  Github To Go
//
//  Created by Robert Panzer on 09.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GithubEvent.h"

@interface GithubEvent() 

-(void)parseCommitComment:(NSDictionary*)jsonObject;

-(void)parsePushEvent:(NSDictionary*)jsonObject;

-(void)parseIssueCommentEvent:(NSDictionary*)jsonObject;

-(void)parsePullRequestEvent:(NSDictionary*)jsonObject;

-(void)parseForkEvent:(NSDictionary*)jsonObject;

-(void)parseWatchEvent:(NSDictionary*)jsonObject;
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
            if ([type isEqualToString:@"PushEvent"]) {
                [self parsePushEvent:jsonObject];
            } else if ([type isEqualToString:@"IssueCommentEvent"]) {
                [self parseIssueCommentEvent:jsonObject];
            } else if ([type isEqualToString:@"PullRequestEvent"]) {
                [self parsePullRequestEvent:jsonObject];
            } else if ([type isEqualToString:@"ForkEvent"]) {
                [self parseForkEvent:jsonObject];
            } else if ([type isEqualToString:@"CommitCommentEvent"]) {
                [self parseCommitComment:jsonObject];
            } else if ([type isEqualToString:@"WatchEvent"]) {
                [self parseWatchEvent:jsonObject];
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


-(void)parsePushEvent:(NSDictionary*)jsonObject {

    NSNumber* commitCount = [jsonObject valueForKeyPath:@"payload.size"];
    if (commitCount.intValue == 1) {
        NSArray* commits = [jsonObject valueForKeyPath:@"payload.commits"];
        NSDictionary* commit = [commits objectAtIndex:0];
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
@end
