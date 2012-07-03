//
//  UIRepositoryRootViewController.h
//  Github To Go
//
//  Created by Robert Panzer on 29.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Repository.h"

#import "RepositoryViewController.h"
#import "BranchesBrowserViewController.h"
#import "EventTableViewController.h"
#import "PullRequestListTableViewController.h"
#import "IssueListViewController.h"
#import "RPFlickViewController.h"

@interface UIRepositoryRootViewController : RPFlickViewController

@property(strong) Repository* repository;
@property BOOL watched;


- (id)initWithRepository:(Repository*)aRepository;

@end
