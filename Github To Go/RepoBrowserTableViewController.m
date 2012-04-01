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

@implementation RepoBrowserTableViewController

@synthesize myRepos;
@synthesize watchedRepos;
//@synthesize repoSearchTableViewController;
@synthesize initialized;


- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];//NibName:@"RepoBrowserTableViewController" bundle:nil];
    if (self) {
        self.title = NSLocalizedString(@"Repositories", @"Repositories");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
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
    self.tableView.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 20.0f, 20.0f)];
    self.tableView.backgroundView.backgroundColor = [UIColor lightGrayColor];

//    repoSearchTableViewController = [[RepoSearchTableViewController alloc] init];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
//    self.repoSearchTableViewController = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
    [self onFetchRepos];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.myRepos.count + 1;
    } else if (section == 1) {
        return self.watchedRepos.count + 1;
    } else if (section == 2) {
        return 1;
    } else {
        return -1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];

    }
    
    if (indexPath.section == 2) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        cell.textLabel.text = @"Find";
        cell.detailTextLabel.text = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        return cell;
    }
    
    if (indexPath.row == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        cell.detailTextLabel.text = nil;
        if (indexPath.section == 0) {
            cell.textLabel.text = @"My Repositories";
        } else {
            cell.textLabel.text = @"Watched Repositories";
        }
        return cell;
    } 

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:11.0f];

    // Configure the cell...
    Repository* repo = nil;
    if (indexPath.section == 0) {
        repo = (Repository*)[myRepos objectAtIndex:indexPath.row - 1];
    } else if (indexPath.section == 1) {
        repo = (Repository*)[watchedRepos objectAtIndex:indexPath.row - 1];
    }
    cell.textLabel.text = repo.fullName;
    cell.detailTextLabel.text = repo.description;
    return cell;
}

#pragma mark - Table view delegate

-(NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((indexPath.section == 0 || indexPath.section == 1) && indexPath.row == 0) {
        return 0;
    }
    if (indexPath.section == 2) {
        return 0;
    }
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Repository* repo = nil;
    if (indexPath.section == 0 && indexPath.row > 0) {
        repo = [self.myRepos objectAtIndex:indexPath.row - 1];
    } else if (indexPath.section == 1 && indexPath.row > 0) {
        repo = [self.watchedRepos objectAtIndex:indexPath.row - 1];
    } else if (indexPath.section == 2) {
        RepoSearchTableViewController *repoSearchTableViewController = [[RepoSearchTableViewController alloc] init];

        [self.navigationController pushViewController:repoSearchTableViewController animated:YES];
        return;
    } else {
        return;
    }
    
    UIRepositoryRootViewController* repoViewController = [[UIRepositoryRootViewController alloc] initWithRepository:repo];
    [self.navigationController pushViewController:repoViewController animated:YES];
}


#pragma mark - fetch data

- (IBAction)onFetchRepos {
    if ([Settings sharedInstance].isUsernameSet) {
        [[NetworkProxy sharedInstance] loadStringFromURL:@"https://api.github.com/user/repos" block:^(int statusCode, NSDictionary* headerFields, id data) {
            NSMutableArray* newRepos = [[NSMutableArray alloc] init];
            for (NSDictionary* repoObject in data) {
                [newRepos addObject:[[Repository alloc] initFromJSONObject:repoObject]];
            }

            dispatch_async(dispatch_get_main_queue(), ^(){
                if (self.myRepos.count == newRepos.count) {
                    self.myRepos = newRepos;
                    [self.tableView reloadData];
                } else {
                    [self.tableView beginUpdates];
                    
                    NSMutableArray *oldIndexPaths = [NSMutableArray array];
                    for (int i = 1; i < self.myRepos.count + 1; i++) {
                        [oldIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                    }
                    self.myRepos = nil;
                    
                    [self.tableView deleteRowsAtIndexPaths:oldIndexPaths withRowAnimation:YES];
                    
                    self.myRepos = newRepos;
                    
                    NSMutableArray* newIndexPaths = [[NSMutableArray alloc] init];
                    for (int i = 1; i < self.myRepos.count + 1; i++) {
                        [newIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                    }
                    
                    [self.tableView insertRowsAtIndexPaths:newIndexPaths withRowAnimation:YES];
                    [self.tableView endUpdates];
                }
            });
        }];
        
        [[NetworkProxy sharedInstance] loadStringFromURL:@"https://api.github.com/user/watched" block:^(int statusCode, NSDictionary* headerFields, id data) {
            NSMutableArray* newRepos = [[NSMutableArray alloc] init];

            for (NSDictionary* repoObject in data) {
                Repository* repo = [[Repository alloc] initFromJSONObject:repoObject];
                [[RepositoryStorage sharedStorage] addWatchedRepository:repo];
                if (! [[[Settings sharedInstance] username] isEqualToString: repo.owner.login]) {
                    [newRepos addObject:repo];
                }
            }

            dispatch_async(dispatch_get_main_queue(), ^() {
                if (self.watchedRepos.count == newRepos.count) {
                    self.watchedRepos = newRepos;
                    [self.tableView reloadData];
                } else {
                    NSMutableArray *oldIndexPaths = [NSMutableArray array];
                    for (int i = 1; i < self.watchedRepos.count + 1; i++) {
                        [oldIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:1]];
                    }
                    
                    self.watchedRepos = nil;
                    
                    [self.tableView deleteRowsAtIndexPaths:oldIndexPaths withRowAnimation:YES];
                    
                    self.watchedRepos = newRepos;
                    
                    NSMutableArray* newIndexPaths = [[NSMutableArray alloc] init];
                    for (int i = 1; i < self.watchedRepos.count + 1; i++) {
                        [newIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:1]];
                    }
                    if (newIndexPaths.count > 0) {
                        [self.tableView insertRowsAtIndexPaths:newIndexPaths withRowAnimation:YES];
                    }
                    [self.tableView endUpdates];
                }
            });
        }];
    } else {
        NSMutableArray *oldIndexPaths = [NSMutableArray array];
        for (int i = 1; i < self.myRepos.count + 1; i++) {
            [oldIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        for (int i = 1; i < self.watchedRepos.count + 1; i++) {
            [oldIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:1]];
        }
        self.myRepos = nil;
        self.watchedRepos = nil;
        [self.tableView deleteRowsAtIndexPaths:oldIndexPaths withRowAnimation:YES];

    }
}

-(void)reload {
    [self onFetchRepos];
}

@end



@implementation RepoSearchTableViewController 

@synthesize repos, searchBar, letUserSelectCells;

- (id)init
{
    self = [super initWithNibName:@"RepoSearchTableViewController" bundle:nil];
    if (self) {
        letUserSelectCells = YES;
    }
    return self;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.frame = CGRectMake(0.0f, 40.0f, self.tableView.frame.size.width, self.tableView.frame.size.height - 40.0f);
    self.tableView.tableHeaderView = self.searchBar;
    
}

-(void)viewDidUnload {
    self.searchBar = nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.repos.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
    }

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:11.0f];
    
    // Configure the cell...
    Repository* repo = [repos objectAtIndex:indexPath.row];
    cell.textLabel.text = repo.fullName;
    cell.detailTextLabel.text = repo.description;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (letUserSelectCells) {
        Repository* repo = nil;
        repo = [self.repos objectAtIndex:indexPath.row];
        
        UIRepositoryRootViewController* repoViewController = [[UIRepositoryRootViewController alloc] initWithRepository:repo];
        [self.navigationController pushViewController:repoViewController animated:YES];
    } else {
        letUserSelectCells = YES;
        [self.searchBar resignFirstResponder];
    }
}


#pragma mark - UISearchBarDelegate methods



-(void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar {    
    NSString *searchUrl = [NSString stringWithFormat:@"http://github.com/api/v2/json/repos/search/%@", aSearchBar.text];
    
    letUserSelectCells = YES;
    [aSearchBar resignFirstResponder];
    
    [[NetworkProxy sharedInstance] loadStringFromURL:searchUrl block:^(int statusCode, NSDictionary* headerFields, id data) {
        NSMutableArray* newRepos = [[NSMutableArray alloc] init];
        NSArray* foundRepos = [data valueForKey:@"repositories"];
        for (NSDictionary* jsonRepo in foundRepos) {
            Repository* repo = [[Repository alloc] initFromJSONObject:jsonRepo];
            [newRepos addObject:repo]; 
        }
        self.repos = newRepos;
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self.tableView reloadData];
        });
    }];
    
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)aSearchBar {
    letUserSelectCells = NO;
}

@end
