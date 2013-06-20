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
#import "NetworkProxy.h"

@interface RepositoryListViewController ()

@property (strong, nonatomic) NSMutableArray *repositories;

@property (strong, nonatomic) NSMutableArray *repositoryInitialized;

@end


@implementation RepositoryListViewController

- (id)initWithRepositories:(NSArray *)aRepositories
{
    self = [super initWithNibName:@"RepositoryListViewController" bundle:nil];
    if (self) {
        _repositories = [NSMutableArray arrayWithArray:aRepositories];
        _repositoryInitialized = [NSMutableArray arrayWithCapacity:aRepositories.count];
        for (unsigned i=0; i < aRepositories.count; i++ ) {
            _repositoryInitialized[i] = @NO;
        }
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
    return self.repositories.count;
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
    
    if (![@YES isEqual:self.repositoryInitialized[indexPath.row]]) {
        [[NetworkProxy sharedInstance] loadStringFromURL:repo.url block:^(int statusCode, NSDictionary *aHeaderFields, id data) {
            if (statusCode == 200) {
                Repository * newRepo = [[Repository alloc] initFromJSONObject:data];
                self.repositories[indexPath.row] = newRepo;
                self.repositoryInitialized[indexPath.row] = @YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIRepositoryRootViewController *repoViewController = [[UIRepositoryRootViewController alloc] initWithRepository:newRepo];
                    [self.navigationController pushViewController:repoViewController animated:YES];
                });
            }
        }];
    } else {
        UIRepositoryRootViewController *repoViewController = [[UIRepositoryRootViewController alloc] initWithRepository:repo];
        [self.navigationController pushViewController:repoViewController animated:YES];
    }
}

@end
