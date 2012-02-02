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
#import "BranchesBrowserViewController.h"
#import "UITreeRootViewController.h"

@implementation TreeViewController

@synthesize tree;
@synthesize commit;
@synthesize repository;
@synthesize branchName;
@synthesize absolutePath;

-(id)initWithTree:(Tree*)aTree absolutePath:(NSString*)anAbsolutePath commit:(Commit *)aCommit repository:(Repository *)aRepository branchName:(NSString*)aBranchName {
    
    self = [super init];
    if (self) {
        commit = [aCommit retain];
        repository = [aRepository retain];
        self.tree = aTree;
        self.branchName = aBranchName;
        self.absolutePath = anAbsolutePath;
    }
    return self;
}

- (void)dealloc {
    [tree release];
    [commit release];
    [branchName release];
    [repository release];
    [absolutePath release];
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
//    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(offerTreeActions:)] autorelease];
//    self.navigationItem.title = self.branchName;
//    
//    [[NetworkProxy sharedInstance] loadStringFromURL:self.url block:^(int statusCode, NSDictionary* headerFields, id data) {
//        if (statusCode == 200) {
//            NSLog(@"Loaded tree %@", data);
//            self.tree = [[[Tree alloc] initWithJSONObject:data absolutePath:self.absolutePath commitSha:self.commitSha] autorelease];
//            
//            NSString* headerText = [NSString stringWithFormat:@"Path: %@", absolutePath];
//            
//            CGSize headerSize = [headerText sizeWithFont:[UIFont systemFontOfSize:16.0f] 
//                                              constrainedToSize:CGSizeMake(320.0f, 1000.0f) 
//                                                  lineBreakMode:UILineBreakModeWordWrap];
//            
//            UILabel* header = [[[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, headerSize.width, headerSize.height + 10.0f)] autorelease];
//            header.numberOfLines = 0;
//            header.lineBreakMode = UILineBreakModeWordWrap;
//            header.text = headerText;
//            header.opaque = YES;
//            header.backgroundColor = [UIColor clearColor];
//            header.font = [UIFont systemFontOfSize:16.0f];
//            
//            self.tableView.tableHeaderView = header;
//            
//            [self.tableView reloadData];
//        }
//    }];
 


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
            cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
        }
        Tree* file = [self.tree treeAtIndex:indexPath.row];
        cell.textLabel.text = file.name;
        return cell;
    } else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierBlob];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifierBlob] autorelease];
            cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0f;
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
        UITreeRootViewController* treeRootViewController = 
            [[[UITreeRootViewController alloc] initWithUrl:treeUrl
                                              absolutePath:subtree.absolutePath
                                                    commit:self.commit
                                                repository:repository
                                                branchName:branchName] autorelease];
        [self.navigationController pushViewController:treeRootViewController animated:YES];
    } else {
        Blob* blob = [self.tree blobAtIndex:indexPath.row];
        NSString* blobUrl = blob.url;
        BlobViewController* blobViewController = [[[BlobViewController alloc] initWithUrl:blobUrl absolutePath:blob.absolutePath commitSha:self.commit.sha repository:self.repository] autorelease];
        [self.navigationController pushViewController:blobViewController animated:YES];
    }
}


-(void)showTreeHistory:(id)sender {
    
    BranchViewController* branchViewController = [[[BranchViewController alloc] initWithGitObject:tree commitSha:self.commit.sha repository:repository] autorelease];
    [self.navigationController pushViewController:branchViewController animated:YES];
    
}

-(void)offerTreeActions:(id)sender {
    
    UIActionSheet* actionSheet = [[[UIActionSheet alloc] initWithTitle:nil 
                                                              delegate:self 
                                                     cancelButtonTitle:nil 
                                                destructiveButtonTitle:nil 
                                                     otherButtonTitles:@"Show history", @"Switch branch", nil] autorelease];
    [actionSheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        BranchViewController* branchViewController = [[[BranchViewController alloc] initWithGitObject:tree commitSha:self.commit.sha repository:repository] autorelease];
        [self.navigationController pushViewController:branchViewController animated:YES];
    } else if (buttonIndex == 1) {
        UINavigationController* navigationController = self.navigationController;
        [navigationController popToRootViewControllerAnimated:NO];
        BranchesBrowserViewController* branchesBrowserViewController = [[[BranchesBrowserViewController alloc] initWithRepository:repository] autorelease];
        [navigationController pushViewController:branchesBrowserViewController animated:NO];
    }
}

@end
