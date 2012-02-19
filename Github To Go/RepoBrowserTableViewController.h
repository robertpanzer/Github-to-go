//
//  RepoBrowserTableViewController.h
//  TabBarTest
//
//  Created by Robert Panzer on 30.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Repository.h"

@interface RepoSearchTableViewController : UITableViewController <UISearchBarDelegate> 

@property(strong) NSArray* repos;
@property(strong) IBOutlet UISearchBar* searchBar;
@end


@interface RepoBrowserTableViewController : UITableViewController 

- (IBAction)onFetchRepos;
- (IBAction)swiped:(id)sender;

@property(strong) NSArray* myRepos;
@property(strong) NSArray* watchedRepos;
@property(strong) IBOutlet RepoSearchTableViewController* repoSearchTableViewController;
@property BOOL initialized;
@end
