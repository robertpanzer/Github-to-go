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
    
    self = [super initWithNibName:@"TreeViewController" bundle:nil];
    if (self) {
        commit = aCommit;
        repository = aRepository;
        self.tree = aTree;
        self.branchName = aBranchName;
        self.absolutePath = anAbsolutePath;
    }
    return self;
}

-(void)setTree:(Tree *)aTree {
    tree = aTree;
    
    [self.tableView reloadData];
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
    [self.tableView reloadData];
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
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierTree];
            cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
        }
        Tree* file = [self.tree treeAtIndex:indexPath.row];
        cell.textLabel.text = file.name;
        return cell;
    } else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierBlob];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifierBlob];
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



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        Tree* subtree = [self.tree treeAtIndex:indexPath.row];
        NSString* treeUrl = subtree.url;
        dispatch_async(dispatch_get_main_queue(), ^() {
            UITreeRootViewController* treeRootViewController = 
            [[UITreeRootViewController alloc] initWithUrl:treeUrl
                                             absolutePath:subtree.absolutePath
                                                   commit:self.commit
                                               repository:repository
                                               branchName:branchName];
            [self.navigationController pushViewController:treeRootViewController animated:YES];
        });
    } else {
        Blob* blob = [self.tree blobAtIndex:indexPath.row];
        NSString* blobUrl = blob.url;
        dispatch_async(dispatch_get_main_queue(), ^() {
            BlobViewController* blobViewController = [[BlobViewController alloc] initWithUrl:blobUrl absolutePath:blob.absolutePath commitSha:self.commit.sha repository:self.repository];
            [self.navigationController pushViewController:blobViewController animated:YES];
        });
    }
}


-(void)showTreeHistory:(id)sender {
    
    BranchViewController* branchViewController = [[BranchViewController alloc] initWithGitObject:tree absolutePath:self.absolutePath commitSha:self.commit.sha repository:repository];
    [self.navigationController pushViewController:branchViewController animated:YES];
    
}

-(void)offerTreeActions:(id)sender {
    
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
                                                              delegate:self 
                                                     cancelButtonTitle:nil 
                                                destructiveButtonTitle:nil 
                                                     otherButtonTitles:NSLocalizedString(@"Show history", @"Button Show History"), @"Switch branch", nil];
    [actionSheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        BranchViewController* branchViewController = [[BranchViewController alloc] initWithGitObject:tree absolutePath:self.absolutePath commitSha:self.commit.sha repository:repository];
        [self.navigationController pushViewController:branchViewController animated:YES];
    } else if (buttonIndex == 1) {
        UINavigationController* navigationController = self.navigationController;
        [navigationController popToRootViewControllerAnimated:NO];
        BranchesBrowserViewController* branchesBrowserViewController = [[BranchesBrowserViewController alloc] initWithRepository:repository];
        [navigationController pushViewController:branchesBrowserViewController animated:NO];
    }
}

@end
