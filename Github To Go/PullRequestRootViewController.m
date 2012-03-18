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
@synthesize headerView;
@synthesize segmentedControl;
@synthesize infoViewController;
@synthesize pullRequest;
@synthesize reviewTableViewController;
@synthesize commentViewController;

- (IBAction)segmentChanged:(id)sender {
    infoViewController.tableView.tableHeaderView = nil;
    reviewTableViewController.tableView.tableHeaderView = nil;
    commentViewController.tableView.tableHeaderView = nil;
    
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            [reviewTableViewController removeFromParentViewController];
            [reviewTableViewController.view removeFromSuperview];
            [commentViewController removeFromParentViewController];
            [commentViewController.view removeFromSuperview];
            [self addChildViewController:infoViewController];
            [self.view addSubview:infoViewController.tableView];
            infoViewController.tableView.tableHeaderView = self.headerView;
            break;
        case 1:
            [infoViewController removeFromParentViewController];
            [infoViewController.view removeFromSuperview];
            [commentViewController removeFromParentViewController];
            [commentViewController.view removeFromSuperview];
            [self addChildViewController:reviewTableViewController];
            [self.view addSubview:reviewTableViewController.tableView];
            reviewTableViewController.tableView.tableHeaderView = self.headerView;
            break;
        case 2:
            [infoViewController removeFromParentViewController];
            [infoViewController.view removeFromSuperview];
            [reviewTableViewController removeFromParentViewController];
            [reviewTableViewController.view removeFromSuperview];
            [self addChildViewController:commentViewController];
            [self.view addSubview:commentViewController.tableView];
            commentViewController.tableView.tableHeaderView = self.headerView;
            break;
        
    }
    infoViewController.view.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    reviewTableViewController.view.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    commentViewController.view.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);

}

- (id)initWithPullRequest:(PullRequest *)aPullRequest
{
    self = [super initWithNibName:@"PullRequestRootViewController" bundle:nil];
    if (self) {
        self.pullRequest = aPullRequest;
        self.infoViewController = [[PullRequestTableViewController alloc] initWithPullRequest:self.pullRequest];
        self.reviewTableViewController = [[PullRequestReviewTableViewController alloc] initWithPullRequest:self.pullRequest];
        self.commentViewController = [[PullRequestCommentViewController alloc] initWithPullRequest:self.pullRequest];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.infoViewController.view.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    
    [self.view addSubview:infoViewController.tableView];
    [self addChildViewController:infoViewController];
    infoViewController.tableView.tableHeaderView = self.headerView;
    
    self.reviewTableViewController.view.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);

    self.commentViewController.view.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    


}

- (void)viewDidUnload
{
    [self setHeaderView:nil];
    [self setSegmentedControl:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end