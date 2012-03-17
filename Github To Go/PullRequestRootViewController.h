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


@interface PullRequestRootViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (strong, nonatomic) PullRequestTableViewController* infoViewController;
@property (strong, nonatomic) PullRequestReviewTableViewController* reviewTableViewController;
@property (strong, nonatomic) PullRequestCommentViewController *commentViewController;

@property (strong, nonatomic) PullRequest* pullRequest;

- (IBAction)segmentChanged:(id)sender;

-(id)initWithPullRequest:(PullRequest*)aPullRequest;

@end
