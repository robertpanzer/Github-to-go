//
//  PullRequestRootViewController.m
//  Github To Go
//
//  Created by Robert Panzer on 12.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PullRequestRootViewController.h"
#import "RPShareUrlController.h"

@interface PullRequestRootViewController ()

@property(nonatomic,strong) RPShareUrlController *shareUrlController;

@end

@implementation PullRequestRootViewController
@synthesize segmentedControl;
@synthesize pullRequest;
@synthesize shareUrlController;

- (id)initWithPullRequest:(PullRequest*)aPullRequest
{
    self = [super init];
    if (self) {
        pullRequest = aPullRequest;
        UIViewController* infoViewController = [[PullRequestTableViewController alloc] initWithPullRequest:self.pullRequest];
        UIViewController* reviewTableViewController = [[PullRequestReviewTableViewController alloc] initWithPullRequest:self.pullRequest];
        UIViewController* commentViewController = [[PullRequestCommentViewController alloc] initWithUrl:aPullRequest.issueCommentsUrl number:aPullRequest.number];
        UIViewController* commitsViewController = [[BranchViewController alloc] initWithPullRequest:self.pullRequest];
        
        [self addChildViewController:infoViewController title:@"Info"];
        [self addChildViewController:reviewTableViewController title:@"Review"];
        [self addChildViewController:commentViewController title:@"Comments"];
        [self addChildViewController:commitsViewController title:@"Commits"];
        
        NSString *shareTitle = [NSString stringWithFormat:@"Pull Request %@", pullRequest.number];
        self.shareUrlController = [[RPShareUrlController alloc] initWithUrl:pullRequest.htmlUrl 
                                                                      title:shareTitle
                                                             viewController:self];
    }
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.shareUrlController.barButtonItem;
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
