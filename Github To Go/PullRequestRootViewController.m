//
//  PullRequestRootViewController.m
//  Github To Go
//
//  Created by Robert Panzer on 12.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PullRequestRootViewController.h"


@interface PullRequestRootViewController ()

@end

@implementation PullRequestRootViewController
@synthesize segmentedControl;
@synthesize pullRequest;

- (id)initWithPullRequest:(PullRequest *)aPullRequest
{
    self = [super init];
    if (self) {
        self.pullRequest = aPullRequest;
        UIViewController* infoViewController = [[PullRequestTableViewController alloc] initWithPullRequest:self.pullRequest];
        UIViewController* reviewTableViewController = [[PullRequestReviewTableViewController alloc] initWithPullRequest:self.pullRequest];
        UIViewController* commentViewController = [[PullRequestCommentViewController alloc] initWithPullRequest:self.pullRequest];
        UIViewController* commitsViewController = [[BranchViewController alloc] initWithPullRequest:self.pullRequest];
        
        [self addChildViewController:infoViewController title:@"Info"];
        [self addChildViewController:reviewTableViewController title:@"Review"];
        [self addChildViewController:commentViewController title:@"Comments"];
        [self addChildViewController:commitsViewController title:@"Commits"];
        
    }
    return self;
}



-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.title = [NSString stringWithFormat:@"Pull %@", self.pullRequest.number];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
