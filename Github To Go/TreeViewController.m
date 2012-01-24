//
//  TreeViewController.m
//  Github To Go
//
//  Created by Robert Panzer on 04.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TreeViewController.h"
#import "BlobViewController.h"
#import "NetworkProxy.h"
#import "Tree.h"
#import "Blob.h"
#import "BranchViewController.h"

@implementation TreeViewController

@synthesize tree;
@synthesize commitSha;
@synthesize repository;

-(id)initWithUrl:(NSString*)anUrl absolutePath:(NSString*)anAbsolutePath commitSha:(NSString *)aCommitSha repository:(Repository *)aRepository {
    
    commitSha = [aCommitSha retain];
    repository = [aRepository retain];
    
    self = [super initWithNibName:@"TreeViewController" bundle:nil];
    if (self) {
        self.navigationItem.title = [anAbsolutePath pathComponents].lastObject;
        
        [[NetworkProxy sharedInstance] loadStringFromURL:anUrl block:^(int statusCode, NSDictionary* headerFields, id data) {
            if (statusCode == 200) {
                NSLog(@"Loaded tree %@", data);
                self.tree = [[[Tree alloc] initWithJSONObject:data absolutePath:anAbsolutePath commitSha:self.commitSha] autorelease];
                [(UITableView*)self.view reloadData];
            }
        }];
    }
    return self;
}

- (void)dealloc {
    [tree release];
    [commitSha release];
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
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showTreeHistory:)] autorelease];

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
    if (tree == nil) {
        return 0;
    } else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
//    return treeContent.count;
    if (section == 0) {
        return tree.subtreeCount;
    } else if (section == 1) {
        return tree.blobCount;
    } else {
        @throw [NSString stringWithFormat:@"Section %d out of range!", section];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifierTree = @"TreeCell";
    static NSString *CellIdentifierBlob = @"BlobCell";
    
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierTree];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierTree] autorelease];
        }
        Tree* file = [self.tree treeAtIndex:indexPath.row];
        cell.textLabel.text = file.name;
        return cell;
    } else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierBlob];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifierBlob] autorelease];
        }
        Blob* blob = [self.tree blobAtIndex:indexPath.row];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d bytes", blob.size]; 
        cell.textLabel.text = blob.name;
        return cell;
    } else {
        @throw [NSString stringWithFormat:@"Section %d out of range", indexPath.section];
    }
        
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Trees";   
    } else {
        return @"Blobs";
    }
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
    if (indexPath.section == 0) {
        Tree* subtree = [self.tree treeAtIndex:indexPath.row];
        NSString* treeUrl = subtree.url;
        TreeViewController* newController = [[[TreeViewController alloc] initWithUrl:treeUrl absolutePath:subtree.absolutePath commitSha:commitSha repository:repository] autorelease];
        [self.navigationController pushViewController:newController animated:YES];
    } else {
        Blob* blob = [self.tree blobAtIndex:indexPath.row];
        NSString* blobUrl = blob.url;
        BlobViewController* blobViewController = [[[BlobViewController alloc] initWithUrl:blobUrl absolutePath:blob.absolutePath commitSha:self.commitSha repository:self.repository] autorelease];
        [self.navigationController pushViewController:blobViewController animated:YES];
    }
}


-(void)showTreeHistory:(id)sender {
    
    BranchViewController* branchViewController = [[[BranchViewController alloc] initWithGitObject:tree commitSha:self.commitSha repository:repository] autorelease];
    [self.navigationController pushViewController:branchViewController animated:YES];
    
}

@end
