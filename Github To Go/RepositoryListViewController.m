//
//  RepositoryListViewController.m
//  Github To Go
//
//  Created by Robert Panzer on 01.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RepositoryListViewController.h"
#import "UITableViewCell+Repository.h"
#import "UIRepositoryRootViewController.h"

@interface RepositoryListViewController ()

@end

@implementation RepositoryListViewController

@synthesize repositories;

- (id)initWithRepositories:(NSArray *)aRepositories
{
    self = [super initWithNibName:@"RepositoryListViewController" bundle:nil];
    if (self) {
        self.repositories = aRepositories;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return repositories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Repository *repo = [self.repositories objectAtIndex:indexPath.row];
    UITableViewCell *cell = [UITableViewCell createRepositoryCellForTableView:self.tableView];
    [cell bindRepository:repo tableView:self.tableView];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Repository *repo = [self.repositories objectAtIndex:indexPath.row];
    UIRepositoryRootViewController *repoViewController = [[UIRepositoryRootViewController alloc] initWithRepository:repo];
    [self.navigationController pushViewController:repoViewController animated:YES];
    
}

@end
