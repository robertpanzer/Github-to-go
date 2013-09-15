//
//  SearchTableViewController.m
//  Github To Go
//
//  Created by Robert Panzer on 01.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SearchTableViewController.h"
#import "NetworkProxy.h"
#import "Repository.h"
#import "UITableViewCell+Repository.h"
#import "UITableViewCell+Person.h"
#import "UIRepositoryRootViewController.h"
#import "PersonViewController.h"
#import "PersonListTableViewController.h"
#import "RepositoryListViewController.h"

static NSArray *kTitles; 


@interface SearchTableViewController ()

@end

@implementation SearchTableViewController
@synthesize searchBar;
@synthesize foundRepos, foundUsers, letUserSelectCells;

+(void)initialize {
    kTitles = [NSArray arrayWithObjects:
               NSLocalizedString(@"Repositories", @"Repositories Search Result"),
               NSLocalizedString(@"Users", @"Users Search Result"),
               nil];
}

- (id)init
{
    self = [super initWithNibName:@"SearchTableViewController" bundle:nil];
    if (self) {
        self.tabBarItem = [[UITabBarItem alloc]initWithTabBarSystemItem:UITabBarSystemItemSearch tag:0];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.tableHeaderView = self.searchBar;
    self.searchBar.delegate = self;

    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        UIImage *backgroundImage = [UIImage imageNamed:@"background"];
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
        self.tableView.backgroundView = backgroundImageView;
    }
}

- (void)viewDidUnload
{
    [self setSearchBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if (self.foundRepos.count < 6) {
            return self.foundRepos.count + 1;
        } else {
            return 7;
        }
    } else {
        if (self.foundUsers.count < 6) {
            return self.foundUsers.count + 1;
        } else {
            return 7;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    if (indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        }
        cell.textLabel.text = [kTitles objectAtIndex:indexPath.section];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    if (indexPath.row == 6) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        }
        cell.textLabel.text = NSLocalizedString(@"Show all", @"Show all search results");
        return cell;
    }
    
    if (indexPath.section == 0) {
        Repository *repo = [self.foundRepos objectAtIndex:indexPath.row - 1];
        UITableViewCell *cell = [UITableViewCell createRepositoryCellForTableView:self.tableView];
        [cell bindRepository:repo tableView:self.tableView];
        return cell;
    }
    if (indexPath.section == 1) {
        Person *person = [self.foundUsers objectAtIndex:indexPath.row - 1];
        UITableViewCell *cell = [UITableViewCell createSimplePersonCellForTableView:self.tableView];
        [cell bindPerson:person tableView:self.tableView];
        return cell;
    }
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.letUserSelectCells) {
        [self.searchBar resignFirstResponder];
        self.letUserSelectCells = YES;
        return;
    } 
    if (indexPath.section == 0) {
        if (indexPath.row > 0 && indexPath.row < 6) {
            Repository * repo = [self.foundRepos objectAtIndex:indexPath.row - 1];
            UIRepositoryRootViewController *repoViewController = [[UIRepositoryRootViewController alloc] initWithRepository:repo];
            [self.navigationController pushViewController:repoViewController animated:YES];
        } else if (indexPath.row == 6) {
            RepositoryListViewController *repoListViewController = [[RepositoryListViewController alloc] initWithRepositories:self.foundRepos];
            repoListViewController.title = NSLocalizedString(@"Search Results", @"Search Results");
            [self.navigationController pushViewController:repoListViewController animated:YES];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row > 0 && indexPath.row < 6) {
            Person *person = [self.foundUsers objectAtIndex:indexPath.row - 1];
            [[NetworkProxy sharedInstance] loadStringFromURL:person.url block:^(int statusCode, NSDictionary *aHeaderFields, id data) {
                if (statusCode == 200) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        Person *newPerson = [[Person alloc] initWithJSONObject:data];
                        PersonViewController *pwc = [[PersonViewController alloc] initWithPerson:newPerson];
                        [self.navigationController pushViewController:pwc animated:YES];
                    });
                }
            }];
        } else if (indexPath.row == 6) {
            PersonListTableViewController *personListTableViewController = [[PersonListTableViewController alloc] initWithPersons:self.foundUsers title:NSLocalizedString(@"Search Result", @"Search Result")];
            [self.navigationController pushViewController:personListTableViewController animated:YES];
        }
    }
}


-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    self.letUserSelectCells = NO;
    return YES;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar {    
    self.letUserSelectCells = YES;
    [aSearchBar resignFirstResponder];
    NSString *searchRepoUrl = [NSString stringWithFormat:@"https://api.github.com/legacy/repos/search/%@", aSearchBar.text ];    
    [[NetworkProxy sharedInstance] loadStringFromURL:searchRepoUrl block:^(int statusCode, NSDictionary* headerFields, id data) {
        NSMutableArray* newRepos = [[NSMutableArray alloc] init];
        if (statusCode == 200) {
            NSArray* foundRepositories = [data valueForKey:@"repositories"];
            for (NSDictionary* jsonRepo in foundRepositories) {
                Repository* repo = [[Repository alloc] initFromJSONObject:jsonRepo];
                [newRepos addObject:repo]; 
            }
        }
        self.foundRepos = newRepos;
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self.tableView reloadData];
        });
    }];


    NSString *searchUserUrl = [NSString stringWithFormat:@"https://api.github.com/legacy/user/search/%@", aSearchBar.text ];    
    [[NetworkProxy sharedInstance] loadStringFromURL:searchUserUrl block:^(int statusCode, NSDictionary* headerFields, id data) {
        NSMutableArray* newUsers = [[NSMutableArray alloc] init];
        if (statusCode == 200) {
            NSArray* newFoundUsers = [data valueForKey:@"users"];
            for (NSDictionary* jsonUser in newFoundUsers) {
                Person* user = [[Person alloc] initWithJSONObject:jsonUser];
                [newUsers addObject:user]; 
            }
        }
        self.foundUsers = newUsers;
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self.tableView reloadData];
        });
    }];

}


@end
