//
//  PullRequestTableViewController.h
//  Github To Go
//
//  Created by Robert Panzer on 10.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullRequest.h"

@interface PullRequestTableViewController : UITableViewController

@property(strong, nonatomic) PullRequest* pullRequest;
@property(strong, nonatomic) NSArray* issueComments;
@property(strong, nonatomic) NSArray* reviewComments;

-(id) initWithPullRequest:(PullRequest*)aPullRequest;

@end
