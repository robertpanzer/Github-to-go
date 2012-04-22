//
//  IssueListViewController.h
//  Hub To Go
//
//  Created by Robert Panzer on 22.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Repository.h"
#import "PullToRefreshTableViewController.h"

@interface IssueListViewController : PullToRefreshTableViewController

@property(strong, nonatomic) NSMutableArray *issues;

@property(strong, nonatomic) Repository *repository;

-(id)initWithRepository:(Repository*)aRepository;
@end
