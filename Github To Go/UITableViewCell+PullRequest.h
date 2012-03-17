//
//  UITableViewCell+PullRequest.h
//  Github To Go
//
//  Created by Robert Panzer on 11.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullRequest.h"

@interface UITableViewCell (PullRequest)

+(UITableViewCell *)createPullRequestIssueCommentCellForTableView:(UITableView*)tableView;
-(void)bindPullRequestIssueComment:(PullRequestIssueComment*)issueComment tableView:(UITableView*)tableView;
+(CGFloat)tableView:(UITableView *)tableView heightForRowForIssueComment:(PullRequestIssueComment*)issueComment;

@end
