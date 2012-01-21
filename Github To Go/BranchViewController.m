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

-(Commit*)commitForIndexPath:(NSIndexPath*)indexPath;

@end




@implementation BranchViewController

@synthesize missingCommits;
@synthesize repository;
@synthesize branch;

-(id)initWithRepository:(Repository*)aRepository andBranch:(Branch*)aBranch {
    self = [super initWithNibName:@"BranchViewController" bundle:nil];
    if (self) {
        self.repository = aRepository;
        self.branch = aBranch;
        missingCommits = [[NSMutableSet alloc] init];
        commitHistoryList = [[CommitHistoryList alloc] init];
        self.navigationItem.title = aBranch.name;
        [self loadCommits];
        
    }
    return self;
}

- (void)dealloc {
    [missingCommits release];
    [repository release];
    [branch release];
    [commitHistoryList release];
    [super dealloc];
}

-(Commit *)commitForIndexPath:(NSIndexPath *)indexPath {
    NSString* date = [commitHistoryList.dates objectAtIndex:indexPath.section];
    return [[commitHistoryList commitsForDay:date] objectAtIndex:indexPath.row];
}

-(void)loadCommits {
    NSString* sha = nil;
    if (commitHistoryList.dates.count == 0) {
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
                [commitHistoryList addCommit:commit];
                
                if ([missingCommits containsObject:commit.sha]) {
                    [self.missingCommits removeObject:commit.sha];
                }
                for (NSString* parent in commit.parentCommitShas) {
                    [self.missingCommits addObject:parent];
                }
                
            }
            for (NSString* missingCommit in missingCommits) {
                NSLog(@"Missing commit: %@", missingCommit);
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
//    return 1;
    return commitHistoryList.dates.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString* date = [commitHistoryList.dates objectAtIndex:section];
    NSArray* commitsForDay = [commitHistoryList commitsForDay:date];
    int commitCount = commitsForDay.count;
    
    // Return the number of rows in the section.
    if (commitHistoryList == nil) {
        return 0;
    } else if (self.missingCommits.count == 0 || section < commitHistoryList.dates.count - 1) {
        return commitCount;
    } else {
        return commitCount + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static NSString *CommitCellIdentifier = @"CommitCell";
    
    static NSInteger MESSAGE_TAG = 1;
    static NSInteger AUTHOR_TAG = 2;
    static NSInteger SHA_TAG = 3;
    UITableViewCell *cell = nil;
    UILabel* messageLabel = nil;
    UILabel* shaLabel = nil;
    UILabel* authorLabel = nil;
    
    NSString* date = [commitHistoryList.dates objectAtIndex:indexPath.section];
    NSArray* commitsForDay = [commitHistoryList commitsForDay:date];
    
    BOOL isCommit = indexPath.section < commitHistoryList.dates.count - 1 || 
    (indexPath.section == commitHistoryList.dates.count - 1 && indexPath.row < commitsForDay.count);
    
    if (isCommit) {
        cell = [tableView dequeueReusableCellWithIdentifier:CommitCellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CommitCellIdentifier] autorelease];
            
            messageLabel = [[[UILabel alloc] initWithFrame:CGRectMake(3.0f, 3.0f, 314.0f, 15.0f)] autorelease];
            messageLabel.font = [UIFont systemFontOfSize:14.0f];
            messageLabel.tag = MESSAGE_TAG;
            messageLabel.textAlignment = UITextAlignmentLeft;
            messageLabel.textColor = [UIColor blackColor];
            [cell.contentView addSubview:messageLabel];
            
            shaLabel = [[[UILabel alloc] initWithFrame:CGRectMake(240.0f, 20.0f, 77.0f, 15.0f)] autorelease];
            shaLabel.font = [UIFont systemFontOfSize:11.0f];
            shaLabel.tag = SHA_TAG;
            shaLabel.textAlignment = UITextAlignmentRight;
            shaLabel.textColor = [UIColor lightGrayColor];
            [cell.contentView addSubview:shaLabel];
            
            
            authorLabel = [[[UILabel alloc] initWithFrame:CGRectMake(3.0f, 20.0f, 200.0f, 14.0f)] autorelease];
            authorLabel.font = [UIFont systemFontOfSize:11.0f];
            authorLabel.tag = AUTHOR_TAG;
            authorLabel.textAlignment = UITextAlignmentLeft;
            authorLabel.textColor = [UIColor lightGrayColor];
            [cell.contentView addSubview:authorLabel];
            
        } else {
            messageLabel = (UILabel*)[cell.contentView viewWithTag:MESSAGE_TAG];
            shaLabel = (UILabel*)[cell.contentView viewWithTag:SHA_TAG];
            authorLabel =  (UILabel*)[cell.contentView viewWithTag:AUTHOR_TAG];
            
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        }
    }
    
    if (isCommit) {
        Commit* commit = [commitsForDay objectAtIndex:indexPath.row];
        messageLabel.text = commit.message;
        shaLabel.text = [commit.sha substringToIndex:7];
        authorLabel.text = commit.author.name;
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* date = [commitHistoryList.dates objectAtIndex:indexPath.section];
    BOOL isCommit = indexPath.section < commitHistoryList.dates.count - 1 || 
    (indexPath.section == commitHistoryList.dates.count - 1 && indexPath.row < [commitHistoryList commitsForDay:date].count);

    if (isCommit) {
        return 36;
    } else {
        return 50;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [commitHistoryList.dates objectAtIndex:section];
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
    NSString* date = [commitHistoryList.dates objectAtIndex:indexPath.section];
    BOOL isCommit = indexPath.section < commitHistoryList.dates.count - 1 || 
    (indexPath.section == commitHistoryList.dates.count - 1 && indexPath.row < [commitHistoryList commitsForDay:date].count);

    if (isCommit) {
        
        Commit* commit = [self commitForIndexPath:indexPath];  //[commits objectAtIndex:indexPath.row];
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
