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
@synthesize infoViewController;
@synthesize pullRequest;
@synthesize reviewTableViewController;
@synthesize commentViewController;
@synthesize commitsViewController;


- (IBAction)segmentChanged:(id)sender {
    
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            [reviewTableViewController removeFromParentViewController];
            [reviewTableViewController.view removeFromSuperview];
            [commentViewController removeFromParentViewController];
            [commentViewController.view removeFromSuperview];
            [commitsViewController removeFromParentViewController];
            [commitsViewController.view removeFromSuperview];
            [self addChildViewController:infoViewController];
            [self.view addSubview:infoViewController.tableView];
            break;
        case 1:
            [infoViewController removeFromParentViewController];
            [infoViewController.view removeFromSuperview];
            [commentViewController removeFromParentViewController];
            [commentViewController.view removeFromSuperview];
            [commitsViewController removeFromParentViewController];
            [commitsViewController.view removeFromSuperview];
            [self addChildViewController:reviewTableViewController];
            [self.view addSubview:reviewTableViewController.tableView];
            break;
        case 2:
            [infoViewController removeFromParentViewController];
            [infoViewController.view removeFromSuperview];
            [reviewTableViewController removeFromParentViewController];
            [reviewTableViewController.view removeFromSuperview];
            [commitsViewController removeFromParentViewController];
            [commitsViewController.view removeFromSuperview];
            [self addChildViewController:commentViewController];
            [self.view addSubview:commentViewController.tableView];
            break;
        case 3:
            [infoViewController removeFromParentViewController];
            [infoViewController.view removeFromSuperview];
            [reviewTableViewController removeFromParentViewController];
            [reviewTableViewController.view removeFromSuperview];
            [commentViewController removeFromParentViewController];
            [commentViewController.view removeFromSuperview];
            [self addChildViewController:commitsViewController];
            [self.view addSubview:commitsViewController.tableView];
            break;
            
        
    }
    self.infoViewController.view.frame = CGRectMake(0.0f, 44.0f, self.view.frame.size.width, self.view.frame.size.height - 44.0f);
    self.reviewTableViewController.view.frame = CGRectMake(0.0f, 44.0f, self.view.frame.size.width, self.view.frame.size.height - 44.0f);
    self.commentViewController.view.frame = CGRectMake(0.0f, 44.0f, self.view.frame.size.width, self.view.frame.size.height - 44.0f);
    self.commitsViewController.view.frame = CGRectMake(0.0f, 44.0f, self.view.frame.size.width, self.view.frame.size.height - 44.0f);

}

- (id)initWithPullRequest:(PullRequest *)aPullRequest
{
    self = [super initWithNibName:@"PullRequestRootViewController" bundle:nil];
    if (self) {
        self.pullRequest = aPullRequest;
        self.infoViewController = [[PullRequestTableViewController alloc] initWithPullRequest:self.pullRequest];
        self.reviewTableViewController = [[PullRequestReviewTableViewController alloc] initWithPullRequest:self.pullRequest];
        self.commentViewController = [[PullRequestCommentViewController alloc] initWithPullRequest:self.pullRequest];
        self.commitsViewController = [[BranchViewController alloc] initWithPullRequest:self.pullRequest];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.infoViewController.view.frame = CGRectMake(0.0f, 44.0f, self.view.frame.size.width, self.view.frame.size.height - 44.0f);
    
    [self.view addSubview:infoViewController.tableView];
    [self addChildViewController:infoViewController];
    
    self.reviewTableViewController.view.frame = CGRectMake(0.0f, 44.0f, self.view.frame.size.width, self.view.frame.size.height - 44.0f);

    self.commentViewController.view.frame = CGRectMake(0.0f, 44.0f, self.view.frame.size.width, self.view.frame.size.height - 44.0f);
    
    self.commitsViewController.view.frame = CGRectMake(0.0f, 44.0f, self.view.frame.size.width, self.view.frame.size.height - 44.0f);


}

- (void)viewDidUnload
{
    [self setSegmentedControl:nil];
    [super viewDidUnload];
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
