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
@synthesize repoSearchTableViewController;
@synthesize initialized;


- (id)init
{
    self = [super initWithNibName:@"RepoBrowserTableViewController" bundle:nil];
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
//    self.tableView.tableHeaderView = self.searchBar;
//    self.searchBar.delegate = self;
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.repoSearchTableViewController = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self onFetchRepos];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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
        return [myRepos count] + 1;
    } else if (section == 1) {
        return [watchedRepos count] + 1;
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
        [self.navigationController pushViewController:repoSearchTableViewController animated:YES];
        return;
    } else {
        return;
    }
    
    UIRepositoryRootViewController* repoViewController = [[UIRepositoryRootViewController alloc] initWithRepository:repo];
    [self.navigationController pushViewController:repoViewController animated:YES];
}


#pragma mark - fetch data

-(void)swiped:(UIPanGestureRecognizer*)sender {
    UITableView* tableView = (UITableView*)self.view;
    if (sender.state == UIGestureRecognizerStateEnded) {
        NSLog(@"Translation: %f", tableView.contentOffset.y);
        if (tableView.contentOffset.y < -10.0f) {
            [self onFetchRepos];
        }
    } else {
        if (tableView.contentOffset.y < -50.0f) {
            [tableView setContentOffset:CGPointMake(0.0f, -50.0f)];
        }
    }
    
}

- (IBAction)onFetchRepos {
    NSLog(@"Get repositories");
    [[NetworkProxy sharedInstance] loadStringFromURL:@"https://api.github.com/user/repos" block:^(int statusCode, NSDictionary* headerFields, id data) {
        NSLog(@"StatusCode: %d", statusCode);
        NSMutableArray* newRepos = [[NSMutableArray alloc] init];
        NSArray* array = (NSArray*) data;
        NSLog(@"%d elements", [array count]);
        
        if (array.count != self.myRepos.count) {
            [self.tableView beginUpdates];

            NSMutableArray* newIndexPaths = [[NSMutableArray alloc] init];
            NSIndexPath* sectionPath = [NSIndexPath indexPathWithIndex:0];
            for (int i = 1; i < self.myRepos.count + 1; i++) {
                NSIndexPath* rowPath = [sectionPath indexPathByAddingIndex:i];
                [newIndexPaths addObject:rowPath];
            }
            [self.tableView deleteRowsAtIndexPaths:newIndexPaths withRowAnimation:YES];
            

            newIndexPaths = [[NSMutableArray alloc] init];
            for (NSDictionary* repoObject in array) {
                [newRepos addObject:[[Repository alloc] initFromJSONObject:repoObject]];
            }
            self.myRepos = newRepos;
            
            for (int i = 1; i < self.myRepos.count + 1; i++) {
                NSIndexPath* rowPath = [sectionPath indexPathByAddingIndex:i];
                [newIndexPaths addObject:rowPath];
            }
            
            [self.tableView insertRowsAtIndexPaths:newIndexPaths withRowAnimation:YES];
            [self.tableView endUpdates];
        }
    } 
     ];
    
    [[NetworkProxy sharedInstance] loadStringFromURL:@"https://api.github.com/user/watched" block:^(int statusCode, NSDictionary* headerFields, id data) {
        NSLog(@"StatusCode: %d", statusCode);
        NSMutableArray* newRepos = [[NSMutableArray alloc] init];
        NSArray* array = (NSArray*) data;
        NSLog(@"%d elements", [array count]);
        
        for (NSDictionary* repoObject in array) {
            Repository* repo = [[Repository alloc] initFromJSONObject:repoObject];
            [[RepositoryStorage sharedStorage] addWatchedRepository:repo];
            if (! [[[Settings sharedInstance] username] isEqualToString: repo.owner.login]) {
                [newRepos addObject:repo];
            }
        }
        
        if (newRepos.count != self.watchedRepos.count) {
            [self.tableView beginUpdates];

            NSMutableArray* newIndexPaths = [[NSMutableArray alloc] init];
            NSIndexPath* sectionPath = [NSIndexPath indexPathWithIndex:1];
            for (int i = 1; i < self.watchedRepos.count + 1; i++) {
                NSIndexPath* rowPath = [sectionPath indexPathByAddingIndex:i];
                [newIndexPaths addObject:rowPath];
            }
            [self.tableView deleteRowsAtIndexPaths:newIndexPaths withRowAnimation:YES];

            self.watchedRepos = newRepos;
            newIndexPaths = [[NSMutableArray alloc] init];
            sectionPath = [NSIndexPath indexPathWithIndex:1];
            for (int i = 1; i < self.watchedRepos.count + 1; i++) {
                NSIndexPath* rowPath = [sectionPath indexPathByAddingIndex:i];
                [newIndexPaths addObject:rowPath];
            }
            
            [self.tableView insertRowsAtIndexPaths:newIndexPaths withRowAnimation:YES];
            [self.tableView endUpdates];

        }
    } 
     ];
    
}

@end



@implementation RepoSearchTableViewController 

@synthesize repos, searchBar;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //    self.tableView.tableHeaderView = self.searchBar;
    //    self.searchBar.delegate = self;
    
    self.tableView.tableHeaderView = self.searchBar;
    self.searchBar.delegate = self;
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
    Repository* repo = nil;
    repo = [self.repos objectAtIndex:indexPath.row];

    UIRepositoryRootViewController* repoViewController = [[UIRepositoryRootViewController alloc] initWithRepository:repo];
        [self.navigationController pushViewController:repoViewController animated:YES];
}


#pragma mark - UISearchBarDelegate methods



-(void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar {
    NSLog(@"Jetzt suchen? %@", aSearchBar.text);
    
    NSString *searchUrl = [NSString stringWithFormat:@"http://github.com/api/v2/json/repos/search/%@", aSearchBar.text];
    
    [aSearchBar resignFirstResponder];
    
    [[NetworkProxy sharedInstance] loadStringFromURL:searchUrl block:^(int statusCode, NSDictionary* headerFields, id data) {
        NSMutableArray* newRepos = [[NSMutableArray alloc] init];
        NSArray* foundRepos = [data valueForKey:@"repositories"];
        for (NSDictionary* jsonRepo in foundRepos) {
            Repository* repo = [[Repository alloc] initFromJSONObject:jsonRepo];
            [newRepos addObject:repo]; 
            NSLog(@"Found repo: %@", repo.fullName);
        }
        self.repos = newRepos;
        [self.tableView reloadData];
    }];
    
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)aSearchBar {
}

@end
