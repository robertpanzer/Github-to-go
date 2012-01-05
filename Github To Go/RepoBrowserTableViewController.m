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
#import "Commit.h"
#import "Tree.h"
#import "NetworkProxy.h"
#import "TreeViewController.h"

@implementation RepoBrowserTableViewController

@synthesize myRepos;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"First", @"First");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] 
                                                   initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
                                                   target:self 
                                                   action:@selector(onFetchRepos)] autorelease];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
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
    
//    [self onFetchRepos];
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
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    return [myRepos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    Repository* repo = (Repository*)[myRepos objectAtIndex:indexPath.row];
    cell.textLabel.text = repo.name;
    cell.detailTextLabel.text = repo.description;
    
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        Repository* repo = [self.myRepos objectAtIndex:indexPath.row];
        NSString* masterBranchUrl = [repo urlOfMasterBranch];
        if (masterBranchUrl == nil) {
            NSString* urlString = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/branches", repo.owner.login, repo.name];
            [[NetworkProxy sharedInstance] loadStringFromURL:urlString block:^(int statusCode, id data) {
                NSLog(@"StatusCode: %d", statusCode);
                if (statusCode == 200) {
                    [repo setBranchesFromJSONObject:(NSArray*)data];
                    NSLog(@"Master Branch URL: %@", [repo urlOfMasterBranch]);
                    [self showBranch:[repo urlOfMasterBranch]];
                }
            } 
             ];
        } else {
            [self showBranch:[repo urlOfMasterBranch]];
        }
        
    }
}



#pragma mark - fetch data

- (IBAction)onFetchRepos {
    NSLog(@"Get repositories");
    [[NetworkProxy sharedInstance] loadStringFromURL:@"https://api.github.com/user/repos" block:^(int statusCode, id data) {
            NSLog(@"StatusCode: %d", statusCode);
            NSMutableArray* newRepos = [[[NSMutableArray alloc] init] autorelease];
            NSArray* array = (NSArray*) data;
            NSLog(@"%d elements", [array count]);
            for (NSDictionary* repoObject in array) {
                [newRepos addObject:[[[Repository alloc] initFromJSONObject:repoObject] autorelease]];
            }
            self.myRepos = newRepos;
            [(UITableView*)self.view reloadData];
        } 
    ];
}


-(void)showBranch:(NSString*)urlOfBranch {
    [[NetworkProxy sharedInstance] loadStringFromURL:urlOfBranch block:^(int statusCode, id data) {
        NSLog(@"StatusCode: %d", statusCode);
        NSDictionary* dict = (NSDictionary*)data;
        for (NSString* key in dict.keyEnumerator) {
            NSLog(@"Key: %@", key);
        }
        NSLog(@"Branch: %@", [data objectForKey:@"tree"]);
        Commit* commit = [[[Commit alloc] initWithJSONObject:[(NSDictionary*)data objectForKey:@"commit"]] autorelease];
        TreeViewController* treeViewController = [[[TreeViewController alloc] initWithUrl:commit.treeUrl name:@"/"] autorelease];
        [self.navigationController pushViewController:treeViewController animated:YES];
    } 
     ];

}
@end
