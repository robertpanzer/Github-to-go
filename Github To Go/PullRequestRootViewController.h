//
//  PullRequestRootViewController.h
//  Github To Go
//
//  Created by Robert Panzer on 12.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullRequestTableViewController.h"
#import "PullRequestReviewTableViewController.h"
#import "PullRequestCommentViewController.h"
#import "PullRequest.h"
#import "BranchViewController.h"
#import "RPFlickViewController.h"

@interface PullRequestRootViewController : RPFlickViewController

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;


@property (strong, nonatomic) PullRequest* pullRequest;

-(id)initWithPullRequest:(PullRequest*)aPullRequest;

@end
