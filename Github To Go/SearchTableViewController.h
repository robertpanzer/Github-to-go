//
//  SearchTableViewController.h
//  Github To Go
//
//  Created by Robert Panzer on 01.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchTableViewController : UITableViewController <UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSArray *foundRepos;
@property (strong, nonatomic) NSArray *foundUsers;
@property (nonatomic) BOOL letUserSelectCells;

@end
