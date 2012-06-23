//
//  IssueRootViewController.m
//  Hub To Go
//
//  Created by Robert Panzer on 17.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IssueRootViewController.h"
#import "Issue.h"
#import "IssueViewController.h"
#import "EventTableViewController.h"
#import "PullRequestCommentViewController.h"

@interface IssueRootViewController ()

@end

@implementation IssueRootViewController

@synthesize issue;

- (id)initWithIssue:(Issue*)anIssue
{
    self = [super init];
    if (self) {
        self.issue = anIssue;
        [self addChildViewController:[[IssueViewController alloc] initWithIssue:anIssue] title:@"Info"];
        NSString* eventsUrl = [NSString stringWithFormat:@"https://api.github.com/repos/%@/issues/%@/events", issue.repository.fullName, issue.number];
        [self addChildViewController:[[EventTableViewController alloc] initWithUrl:eventsUrl] title:@"Events"];
        
        PullRequestCommentViewController *commentViewController = [[PullRequestCommentViewController alloc] initWithUrl:[NSString stringWithFormat:@"https://api.github.com/repos/%@/issues/%@/comments", anIssue.repository.fullName, anIssue.number] number:anIssue.number];
        [self addChildViewController:commentViewController title:@"Comments"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
