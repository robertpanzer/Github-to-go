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
#import "RPShareUrlController.h"

@interface IssueRootViewController ()

@property(nonatomic,strong) RPShareUrlController *shareUrlController;

@end

@implementation IssueRootViewController

@synthesize issue;
@synthesize shareUrlController;

- (id)initWithIssue:(Issue*)anIssue
{
    self = [super init];
    if (self) {
        self.issue = anIssue;
        [self addChildViewController:[[IssueViewController alloc] initWithIssue:anIssue] title:@"Info"];
        NSString* eventsUrl = [NSString stringWithFormat:@"%@/%@/events", issue.repository.issuesUrl, issue.number];
        [self addChildViewController:[[EventTableViewController alloc] initWithUrl:eventsUrl] title:@"Events"];
        
        PullRequestCommentViewController *commentViewController = [[PullRequestCommentViewController alloc] initWithUrl:[NSString stringWithFormat:@"%@/%@/comments", anIssue.repository.issuesUrl, anIssue.number] number:anIssue.number];
        [self addChildViewController:commentViewController title:@"Comments"];
        
        self.navigationItem.title = [anIssue.number description];
        
        NSString *shareTitle = [NSString stringWithFormat:@"Issue %@", issue.number];
        self.shareUrlController = [[RPShareUrlController alloc] initWithUrl:issue.htmlUrl 
                                                                      title:shareTitle
                                                             viewController:self];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.shareUrlController.barButtonItem;
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
