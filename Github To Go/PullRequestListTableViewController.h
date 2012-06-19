//
//  PullRequestListTableViewController.h
//  Github To Go
//
//  Created by Robert Panzer on 09.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Repository.h"
#import "PullToRefreshTableViewController.h"

@interface PullRequestListTableViewController : PullToRefreshTableViewController

@property(strong,nonatomic) NSMutableArray* pullRequests;

@property(strong,nonatomic) Repository* repository;

-initWithRepository:(Repository*)aRepository;

@end
