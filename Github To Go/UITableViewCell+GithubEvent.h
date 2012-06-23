//
//  UITableViewCell+GithubEvent.h
//  Github To Go
//
//  Created by Robert Panzer on 03.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GithubEvent.h"

@interface UITableViewCell (GithubEvent)

-(void)bindGithubEvent:(GithubEvent*)anEvent;

-(void)bindPushEvent:(PushEvent*)anEvent;

-(void)bindPullRequestEvent:(PullRequestEvent*)anEvent;

-(void)bindCommitCommentEvent:(CommitCommentEvent*)anEvent;

-(void)bindPullRequestReviewCommentEvent:(PullRequestReviewCommentEvent*)anEvent;

-(void)bindIssueCommentEvent:(IssueCommentEvent*)anEvent;

-(void)bindIssuesEvent:(IssuesEvent*)anEvent;

@end
