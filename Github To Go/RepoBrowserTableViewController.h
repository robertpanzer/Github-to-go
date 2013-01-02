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

@interface RepoBrowserTableViewController: UITableViewController <UISearchBarDelegate>


@property(strong) NSArray* myRepos;
@property(strong) NSArray* watchedRepos;
@property(strong) NSArray* starredRepos;

@property(strong) NSArray* matchingMyRepos;
@property(strong) NSArray* matchingWatchedRepos;
@property(strong) NSArray* matchingStarredRepos;

@property BOOL initialized;

- (void)onFetchRepos:(NSNotification*)notification;

@end
