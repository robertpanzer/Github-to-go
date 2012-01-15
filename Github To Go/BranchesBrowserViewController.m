//
//  BranchesBrowserViewController.m
//  Github To Go
//
//  Created by Robert Panzer on 06.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BranchesBrowserViewController.h"
#import "NetworkProxy.h"
#import "Branch.h"
#import "TreeViewController.h"
#import "BranchViewController.h"

@implementation BranchesBrowserViewController

@synthesize branches;
@synthesize repository;

-(id)initWithRepository:(Repository*)aRepository {
    self = [super initWithNibName:@"RepositoryViewController" bundle:nil];
    if (self) {
        self.repository = aRepository;
        self.navigationItem.title = repository.fullName;
        NSString* url = [[[NSString alloc] initWithFormat:@"%@/branches", repository.url] autorelease];
        [[NetworkProxy sharedInstance] loadStringFromURL:url block:^(int statusCode, id data) {
            if (statusCode == 200) {
                NSLog(@"Loaded branches %@", data);
                NSMutableArray* newBranches = [[[NSMutableArray alloc] init] autorelease];
                for (NSDictionary* jsonBranch in data) {
                    [newBranches addObject:[[[Branch alloc] initWithJSONObject:jsonBranch] autorelease]];
                }
                self.branches = newBranches;
                [(UITableView*)self.view reloadData];
            }
        }];
    }
    return self;
}

- (void)dealloc {
    [branches release];
    [super dealloc];
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
    if (branches == nil) {
        return 0;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return branches.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    
    Branch* branch = [branches objectAtIndex:indexPath.row];
    cell.textLabel.text = branch.name;
    
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
    Branch* branch = [branches objectAtIndex:indexPath.row];
    NSString* commitUrl = branch.commitUrl;

    [[NetworkProxy sharedInstance] loadStringFromURL:commitUrl block:^(int statusCode, id data) {
        NSLog(@"StatusCode: %d", statusCode);
        Commit* commit = [[[Commit alloc] initWithJSONObject:data repository:repository] autorelease];
        TreeViewController* treeViewController = [[[TreeViewController alloc] initWithUrl:commit.treeUrl name:@"/"] autorelease];
        [self.navigationController pushViewController:treeViewController animated:YES];
    } 
     ];
    
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    Branch* branch = [branches objectAtIndex:indexPath.row];
//    NSString* commitUrl = branch.commitUrl;

    BranchViewController* branchViewController = [[[BranchViewController alloc] initWithRepository:repository andBranch:branch] autorelease];
    [self.navigationController pushViewController:branchViewController animated:YES];
}


@end
