//
//  PullRequestListTableViewController.h
//  Github To Go
//
//  Created by Robert Panzer on 09.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Repository.h"

@interface PullRequestListTableViewController : UITableViewController {

    NSMutableArray* pullRequests;
    
    Repository* repository;
}

@property(strong) NSMutableArray* pullRequests;

@property(strong) Repository* repository;

-initWithRepository:(Repository*)aRepository;

@end
