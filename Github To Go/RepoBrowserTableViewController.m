//
//  RepoBrowserTableViewController.m
//  TabBarTest
//
//  Created by Robert Panzer on 30.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RepoBrowserTableViewController.h"
//#import "SBJson.h"
#import "Repository.h"
#import "RepositoryViewController.h"
#import "Commit.h"
#import "Tree.h"
#import "NetworkProxy.h"
#import "TreeViewController.h"
#import "Branch.h"
#import "Settings.h"
#import "UIRepositoryRootViewController.h"
#import "RepositoryStorage.h"
#import "UITableViewCell+Repository.h"

@implementation RepoBrowserTableViewController


- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.title = NSLocalizedString(@"Repositories", @"Repositories");
        self.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFavorites tag:2];
        self.initialized = NO;
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.tableHeaderView = self.searchDisplayController.searchBar;
    self.navigationController.navigationBarHidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFetchRepos:) name:LOADED_REPOS_NOTIFICATION object:nil];
    [self onFetchRepos:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return NSLocalizedString(@"My Repositories", @"My Repositories section header");
        case 1:
            return NSLocalizedString(@"Watched Repositories", @"Watched Repositories section header");
        case 2:
            return NSLocalizedString(@"Starred Repositories", @"Starred Repositories section header");
        default:
            return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        
        if (section == 0) {
            return self.myRepos.count;
        } else if (section == 1) {
            return self.watchedRepos.count;
        } else if (section == 2) {
            return self.starredRepos.count;
        } else {
            return -1;
        }
    } else {
        // That's the search display view
        if (section == 0) {
            return self.matchingMyRepos.count;
        } else if (section == 1) {
            return self.matchingWatchedRepos.count;
        } else if (section == 2) {
            return self.matchingStarredRepos.count;
        } else {
            return -1;
        }
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [UITableViewCell createRepositoryCellForTableView:self.tableView];
    // Configure the cell...
    Repository* repo = nil;
    if (tableView == self.tableView) {
        switch (indexPath.section) {
            case 0:
                repo = (Repository*)[self.myRepos objectAtIndex:indexPath.row];
                break;
            case 1:
                repo = (Repository*)[self.watchedRepos objectAtIndex:indexPath.row];
                break;
            case 2:
                repo = (Repository*)[self.starredRepos objectAtIndex:indexPath.row];
                break;
        }
    } else {
        switch (indexPath.section) {
            case 0:
                repo = (Repository*)[self.matchingMyRepos objectAtIndex:indexPath.row];
                break;
            case 1:
                repo = (Repository*)[self.matchingWatchedRepos objectAtIndex:indexPath.row];
                break;
            case 2:
                repo = (Repository*)[self.matchingStarredRepos objectAtIndex:indexPath.row];
                break;
        }
    }
    [cell bindRepository:repo tableView:self.tableView];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Repository* repo = nil;
    if (tableView == self.tableView) {
        switch (indexPath.section) {
            case 0:
                repo = (Repository*)[self.myRepos objectAtIndex:indexPath.row];
                break;
            case 1:
                repo = (Repository*)[self.watchedRepos objectAtIndex:indexPath.row];
                break;
            case 2:
                repo = (Repository*)[self.starredRepos objectAtIndex:indexPath.row];
                break;
        }
    } else {
        switch (indexPath.section) {
            case 0:
                repo = (Repository*)[self.matchingMyRepos objectAtIndex:indexPath.row];
                break;
            case 1:
                repo = (Repository*)[self.matchingWatchedRepos objectAtIndex:indexPath.row];
                break;
            case 2:
                repo = (Repository*)[self.matchingStarredRepos objectAtIndex:indexPath.row];
                break;
        }
    }

    if (repo == nil) {
        return;
    }
    UIRepositoryRootViewController* repoViewController = [[UIRepositoryRootViewController alloc] initWithRepository:repo];
    [self.navigationController pushViewController:repoViewController animated:YES];
}


#pragma mark - fetch data

- (void)onFetchRepos:(NSNotification*)notification {

    dispatch_async(dispatch_get_main_queue(), ^(){
        NSDictionary *ownRepos = [RepositoryStorage sharedStorage].ownRepositories;
        NSMutableArray *newRepos = [NSMutableArray array];
        for (Repository *repository in ownRepos.objectEnumerator) {
            [newRepos addObject:repository];
        }
        self.myRepos = newRepos;

        NSDictionary *watchedRepos = [RepositoryStorage sharedStorage].watchedRepositories;
        NSMutableArray *newWatchedRepos = [NSMutableArray array];
        for (Repository *repository in watchedRepos.objectEnumerator) {
            [newWatchedRepos addObject:repository];
        }
        self.watchedRepos = newWatchedRepos;

        NSDictionary *starredRepos = [RepositoryStorage sharedStorage].starredRepositories;
        NSMutableArray *newStarredRepos = [NSMutableArray array];
        for (Repository *repository in starredRepos.objectEnumerator) {
            [newStarredRepos addObject:repository];
        }
        self.starredRepos = newStarredRepos;

        [self.tableView reloadData];
    });
}


#pragma mark - search bar delegate methods


-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSMutableArray *newRepos = [NSMutableArray array];
    for (Repository *repo in self.myRepos) {
        if ([repo matchesSearchString:searchText]) {
            [newRepos addObject:repo];
        }
    }
    self.matchingMyRepos = newRepos;

    newRepos = [NSMutableArray array];
    for (Repository *repo in self.watchedRepos) {
        if ([repo matchesSearchString:searchText]) {
            [newRepos addObject:repo];
        }
    }
    self.matchingWatchedRepos = newRepos;

    newRepos = [NSMutableArray array];
    for (Repository *repo in self.starredRepos) {
        if ([repo matchesSearchString:searchText]) {
            [newRepos addObject:repo];
        }
    }
    self.matchingStarredRepos = newRepos;

    [self.searchDisplayController.searchResultsTableView reloadData];
}

@end



