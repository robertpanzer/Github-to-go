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
#import "UITreeRootViewController.h"

@implementation BranchesBrowserViewController

@synthesize branches;
@synthesize repository;

-(id)initWithRepository:(Repository*)aRepository {
    self = [super initWithNibName:@"BranchesBrowserViewController" bundle:nil];
    if (self) {
        self.repository = aRepository;
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
    self.navigationItem.title = repository.fullName;
    NSString* url = [[NSString alloc] initWithFormat:@"https://api.github.com/repos/%@/branches", repository.fullName];
    [[NetworkProxy sharedInstance] loadStringFromURL:url block:^(int statusCode, NSDictionary* headerFields, id data) {
        if (statusCode == 200) {
            NSLog(@"Loaded branches %@", data);
            NSMutableArray* newBranches = [[NSMutableArray alloc] init];
            for (NSDictionary* jsonBranch in data) {
                [newBranches addObject:[[Branch alloc] initWithJSONObject:jsonBranch]];
            }
            self.branches = newBranches;
            dispatch_async(dispatch_get_main_queue(), ^() {
                [(UITableView*)self.view reloadData];
            });
        }
    }];
    
//    self.tableView.tableHeaderView = self.tableHeader;

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
    if (branches == nil) {
        return 0;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return branches.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
    }
    
    Branch* branch = [branches objectAtIndex:indexPath.row];
    cell.textLabel.text = branch.name;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Branch* branch = [branches objectAtIndex:indexPath.row];
    NSString* commitUrl = branch.commitUrl;

    [[NetworkProxy sharedInstance] loadStringFromURL:commitUrl block:^(int statusCode, NSDictionary* headerFields, id data) {
        NSLog(@"StatusCode: %d", statusCode);
        Commit* commit = [[Commit alloc] initWithJSONObject:data repository:repository];

        dispatch_async(dispatch_get_main_queue(), ^() {
            UITreeRootViewController* treeViewController = [[UITreeRootViewController alloc] initWithUrl:commit.treeUrl absolutePath:@"" commit:commit repository:repository branchName:branch.name];
            [self.navigationController pushViewController:treeViewController animated:YES];
        });
    } 
     ];
    
}


@end
