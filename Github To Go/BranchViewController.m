//
//  BranchViewController.m
//  Github To Go
//
//  Created by Robert Panzer on 07.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BranchViewController.h"

#import "NetworkProxy.h"
#import "Commit.h"
#import "CommitViewController.h"

@interface BranchViewController()

-(void)loadCommits;

@end

@implementation BranchViewController

@synthesize commits;
@synthesize missingCommits;
@synthesize repository;
@synthesize branch;

-(id)initWithRepository:(Repository*)aRepository andBranch:(Branch*)aBranch {
    self = [super initWithNibName:@"BranchViewController" bundle:nil];
    if (self) {
        self.repository = aRepository;
        self.branch = aBranch;
        commits = [[NSMutableArray alloc] init];
        missingCommits = [[NSMutableSet alloc] init];
        self.navigationItem.title = aBranch.name;
        [self loadCommits];
        
    }
    return self;
}

- (void)dealloc {
    [commits release];
    [missingCommits release];
    [repository release];
    [branch release];
    [super dealloc];
}

-(void)loadCommits {
    NSString* sha = nil;
    if (self.commits.count == 0) {
        sha = branch.sha;
    } else {
        sha = [self.missingCommits anyObject];
        [(NSMutableSet*)self.missingCommits removeObject:sha];
    }
    NSString* url = [[[NSString alloc] initWithFormat:@"https://api.github.com/repos/%@/commits?sha=%@", repository.fullName, sha] autorelease];
    [[NetworkProxy sharedInstance] loadStringFromURL:url block:^(int statusCode, id data) {
        if (statusCode == 200) {
            NSArray * jsonCommits = (NSArray*)data;
            for (NSDictionary* jsonCommit in jsonCommits) {
                Commit* commit = [[[Commit alloc] initMinimalDataWithJSONObject:jsonCommit repository:repository] autorelease];
                [(NSMutableArray*)self.commits addObject:commit];
                for (NSString* parent in commit.parentCommitShas) {
                    [self.missingCommits addObject:parent];
                }
            }
            isLoading = NO;
            [(UITableView*)self.view reloadData];
        }
    }];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (self.missingCommits.count == 0 || self.commits == 0) {
        return commits.count;
    } else {
        return commits.count + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if (indexPath.row < commits.count) {
        Commit* commit = [commits objectAtIndex:indexPath.row];
        cell.textLabel.text = commit.message;
        cell.detailTextLabel.text = commit.author.name;
    } else {
        cell.textLabel.text = @"Load More Commits...";
        cell.detailTextLabel.text = nil;
        
        if (!isLoading) {
            isLoading = YES;
            [self loadCommits];
        }

    }
    return cell;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < commits.count) {
        
        Commit* commit = [commits objectAtIndex:indexPath.row];
        CommitViewController* commitViewController = [[[CommitViewController alloc] initWithUrl:commit.commitUrl andName:commit.message repository:repository] autorelease];
        [self.navigationController pushViewController:commitViewController animated:YES];
    }
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
