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

@implementation RepoBrowserTableViewController

@synthesize myRepos;
@synthesize watchedRepos;


- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.title = NSLocalizedString(@"Repositories", @"Repositories");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
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
    
    UITableView* tableView = (UITableView*)self.view;
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, -50.0f, tableView.bounds.size.width, 50.0f)];
    label.text = @"Drop to reload";
    [tableView addSubview:label];

    [tableView.panGestureRecognizer addTarget:self action:@selector(swiped:)]; 
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return [myRepos count];
    } else if (section == 1) {
        return [watchedRepos count];
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
        cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:11.0f];

    }
    
    // Configure the cell...
    Repository* repo = nil;
    if (indexPath.section == 0) {
        repo = (Repository*)[myRepos objectAtIndex:indexPath.row];
    } else if (indexPath.section == 1) {
        repo = (Repository*)[watchedRepos objectAtIndex:indexPath.row];
    }
    cell.textLabel.text = repo.fullName;
    cell.detailTextLabel.text = repo.description;
    
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"My Repositories";   
    } else {
        return @"Watched Repositories";
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel* headerLabel = [[UILabel alloc] init];
    headerLabel.font = [UIFont systemFontOfSize:14.0f];
    headerLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    headerLabel.textAlignment = UITextAlignmentCenter;
    headerLabel.opaque = NO;
    headerLabel.backgroundColor = [UIColor clearColor];
    return headerLabel;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Repository* repo = nil;
    if (indexPath.section == 0) {
        repo = [self.myRepos objectAtIndex:indexPath.row];
    } else if (indexPath.section == 1) {
        repo = [self.watchedRepos objectAtIndex:indexPath.row];
    } else {
        return;
    }
    if (repo.masterBranch == nil) {
//        RepositoryViewController* repoViewController = [[[RepositoryViewController alloc] initWithRepository:repo] autorelease];
//        [self.navigationController pushViewController:repoViewController animated:YES];
        UIRepositoryRootViewController* repoViewController = [[UIRepositoryRootViewController alloc] initWithRepository:repo];
        [self.navigationController pushViewController:repoViewController animated:YES];
    } else {
        NSString* urlString = [NSString stringWithFormat:@"%@/branches", repo.url];
        [[NetworkProxy sharedInstance] loadStringFromURL:urlString block:^(int statusCode, NSDictionary* headerFields, id data) {
            NSLog(@"StatusCode: %d", statusCode);
            if (statusCode == 200) {
                [repo setBranchesFromJSONObject:(NSArray*)data];
                NSLog(@"Master Branch URL: %@", [repo urlOfMasterBranch]);
                [self showMasterBranch:repo];
            }
        } 
         ];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    Repository* repo = nil;
    if (indexPath.section == 0) {
        repo = [self.myRepos objectAtIndex:indexPath.row];
    } else if (indexPath.section == 1) {
        repo = [self.watchedRepos objectAtIndex:indexPath.row];
    } else {
        return;
    }
    
    RepositoryViewController* repoViewController = [[RepositoryViewController alloc] initWithRepository:repo];
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
            for (NSDictionary* repoObject in array) {
                [newRepos addObject:[[Repository alloc] initFromJSONObject:repoObject]];
            }
            self.myRepos = newRepos;
            [(UITableView*)self.view reloadData];
        } 
    ];
    
    [[NetworkProxy sharedInstance] loadStringFromURL:@"https://api.github.com/user/watched" block:^(int statusCode, NSDictionary* headerFields, id data) {
        NSLog(@"StatusCode: %d", statusCode);
        NSMutableArray* newRepos = [[NSMutableArray alloc] init];
        NSArray* array = (NSArray*) data;
        NSLog(@"%d elements", [array count]);
        for (NSDictionary* repoObject in array) {
            Repository* repo = [[Repository alloc] initFromJSONObject:repoObject];
            if (! [[[Settings sharedInstance] username] isEqualToString: repo.owner.login]) {
                [newRepos addObject:repo];
            }
        }
        self.watchedRepos = newRepos;
        [(UITableView*)self.view reloadData];
    } 
     ];

}




-(void)showMasterBranch:(Repository*)repository {
//    NSString* commitUrl = [repository urlOfMasterBranch];
//    [[NetworkProxy sharedInstance] loadStringFromURL:commitUrl block:^(int statusCode, NSDictionary* headerFields, id data) {
//        NSLog(@"StatusCode: %d", statusCode);
//        NSDictionary* dict = (NSDictionary*)data;
//        for (NSString* key in dict.keyEnumerator) {
//            NSLog(@"Key: %@", key);
//        }
//        NSLog(@"Branch: %@", [data objectForKey:@"tree"]);
//        Commit* commit = [[[Commit alloc] initWithJSONObject:data repository:repository] autorelease];
//        TreeViewController* treeViewController = [[[TreeViewController alloc] initWithUrl:commit.treeUrl absolutePath:@"" commitSha:commit.sha repository:repository branchName:repository.masterBranch] autorelease];
//        [self.navigationController pushViewController:treeViewController animated:YES];
//    } 
//     ];

}

@end
