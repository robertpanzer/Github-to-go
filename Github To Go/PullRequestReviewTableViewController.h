//
//  PullRequestReviewTableViewController.h
//  Github To Go
//
//  Created by Robert Panzer on 14.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullRequest.h"

@interface PullRequestReviewTableViewController : UITableViewController

@property (strong, nonatomic) PullRequest* pullRequest;
@property (strong, nonatomic) NSArray *files;
@property (strong, nonatomic) NSDictionary *comments;
-(id) initWithPullRequest:(PullRequest*)aPullRequest;
@end
