//
//  RepoBrowserTableViewController.h
//  TabBarTest
//
//  Created by Robert Panzer on 30.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Repository.h"
#import "PullToRefreshTableViewController.h"

@interface RepoBrowserTableViewController : PullToRefreshTableViewController 

- (IBAction)onFetchRepos;

@property(strong) NSArray* myRepos;
@property(strong) NSArray* watchedRepos;
//// Deprecated
//@property(strong) id repoSearchTableViewController;
@property BOOL initialized;
@end
