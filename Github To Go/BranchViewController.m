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
#import "GitObject.h"
#import "UITableViewCell+Commit.h"

@interface BranchViewController()

-(Commit*)commitForIndexPath:(NSIndexPath*)indexPath;

@end


@implementation BranchViewController

@synthesize repository;
@synthesize branch;
@synthesize absolutePath;
@synthesize commitSha;
@synthesize searchBar;
@synthesize loadNextTableViewCell;
@synthesize fullUrl;

-(id)initWithCommitHistoryList:(CommitHistoryList *)aCommitHistoryList repository:(Repository*)aRepository branch:(Branch*)aBranch {
    self = [super initWithNibName:@"BranchViewController" bundle:nil];
    if (self) {
        isComplete = YES;
        self.repository = aRepository;
        self.branch = aBranch;
        commitSha = branch.sha;
        commitHistoryList = aCommitHistoryList;
        self.navigationItem.title = aBranch.name;
        letUserSelectCells = YES;
        isSearchResult = YES;
    }
    return self;
}

-(id)initWithRepository:(Repository*)aRepository andBranch:(Branch*)aBranch {
    self = [super initWithNibName:@"BranchViewController" bundle:nil];
    if (self) {
        isComplete = NO;
        self.repository = aRepository;
        self.branch = aBranch;
        commitSha = branch.sha;
        commitHistoryList = [[CommitHistoryList alloc] init];
        self.navigationItem.title = aBranch.name;
        letUserSelectCells = YES;
        isSearchResult = NO;
    }
    return self;
}

-(id)initWithGitObject:(id<GitObject>)gitObject absolutePath:(NSString*)anAbsolutePath commitSha:(NSString *)aCommitSha repository:(Repository *)aRepository {
    self = [super initWithNibName:@"BranchViewController" bundle:nil];
    if (self) {
        isComplete = NO;
        self.repository = aRepository;
        commitHistoryList = [[CommitHistoryList alloc] init];
        absolutePath = anAbsolutePath;
        commitSha = aCommitSha;
        
        self.navigationItem.title = [[anAbsolutePath componentsSeparatedByString:@"/"] lastObject];
        letUserSelectCells = YES;
        isSearchResult = NO;
    }
    return self;
}

-(id)initWithPullRequest:(PullRequest *)aPullRequest {
    self = [super initWithNibName:@"BranchViewController" bundle:nil];
    if (self) {
        self.fullUrl = [NSString stringWithFormat:@"%@/commits", aPullRequest.selfUrl];
        self.repository = aPullRequest.repository;
        commitHistoryList = [[CommitHistoryList alloc] init];
        isComplete = YES;
        letUserSelectCells = YES;
    }
    return self;
}


-(Commit *)commitForIndexPath:(NSIndexPath *)indexPath {
    NSString* date = [commitHistoryList.dates objectAtIndex:indexPath.section];
    return [[commitHistoryList commitsForDay:date] objectAtIndex:indexPath.row];
}

-(void)loadCommits {
    NSString* sha = nil;
    NSString* url = nil;
    if (self.fullUrl != nil) {
        url = self.fullUrl;
    } else {
        if (commitHistoryList.dates.count == 0) {
            sha = commitSha;
        } else {
            Commit* lastCommit = [commitHistoryList lastCommit];
            sha = lastCommit.sha;
        }
        url = [[NSString alloc] initWithFormat:@"https://api.github.com/repos/%@/commits?sha=%@", repository.fullName, sha];
        if (absolutePath != nil) {
            url = [url stringByAppendingFormat:@"&path=%@", absolutePath];
        }
    }
    [[NetworkProxy sharedInstance] loadStringFromURL:url block:^(int statusCode, NSDictionary* headerFields, id data) {
        if (statusCode == 200) {
            NSInteger oldCount = commitHistoryList.count;
            
            NSArray * jsonCommits = (NSArray*)data;
            for (NSDictionary* jsonCommit in jsonCommits) {
                Commit* commit = [[Commit alloc] initMinimalDataWithJSONObject:jsonCommit repository:repository];
                [commitHistoryList addCommit:commit];
            }
            isLoading = NO;
            if (oldCount == commitHistoryList.count) {
                isComplete = YES;
            }

            dispatch_async(dispatch_get_main_queue(), ^() {
                [(UITableView*)self.view reloadData];
            });
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
    
    UILabel* loadNextLabel = (UILabel*)[self.loadNextTableViewCell.contentView viewWithTag:2];
    loadNextLabel.text = NSLocalizedString(@"Loading more commits...", @"Commit History Loading More Commits");
    
    if (!isSearchResult) {
        UISearchBar* aSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 45.0f)];
        aSearchBar.delegate = self;
        self.tableView.tableHeaderView = aSearchBar;
        self.tableView.contentOffset = CGPointMake(0.0f, 45.0f);
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.loadNextTableViewCell = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (commitHistoryList.count == 0) {
        [self loadCommits];
    }
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

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
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
    } else if (section < commitHistoryList.dates.count - 1 || isComplete) {
        return commitCount;
    } else {
        return commitCount + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Commit* commit = [commitHistoryList objectAtIndexPath:indexPath];

    if (commit != nil) {
        UITableViewCell *cell = [UITableViewCell createCommitCellForTableView:self.tableView];
        [cell bindCommit:commit tableView:self.tableView];
        return cell;
    } else {
        if (!isLoading) {
            isLoading = YES;
            [self loadCommits];
        }
        return loadNextTableViewCell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Commit* commit = [commitHistoryList objectAtIndexPath:indexPath];
    if (commit != nil) {
        return [UITableViewCell tableView:tableView heightForRowForCommit:commit];
    } else {
        return 50;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [commitHistoryList stringFromInternalDate:[commitHistoryList.dates objectAtIndex:section]];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (letUserSelectCells) {
        NSString* date = [commitHistoryList.dates objectAtIndex:indexPath.section];
        BOOL isCommit = indexPath.section < commitHistoryList.dates.count - 1 || 
        (indexPath.section == commitHistoryList.dates.count - 1 && indexPath.row < [commitHistoryList commitsForDay:date].count);
        
        if (isCommit) {
            Commit* commit = [self commitForIndexPath:indexPath];  //[commits objectAtIndex:indexPath.row];
            CommitViewController* commitViewController = [[CommitViewController alloc] initWithCommit:commit repository:repository];
            [self.navigationController pushViewController:commitViewController animated:YES];
        }
    } else {
        [self.searchBar resignFirstResponder];
        letUserSelectCells = YES;
    }
}

#pragma mark - UISearchBarDelegate methods

-(void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar {
    NSLog(@"Jetzt suchen? %@", aSearchBar.text);
    
    CommitHistoryList* searchResult = [commitHistoryList commitHistoryListFilteredBySearchString:searchBar.text];
    BranchViewController* searchResultController = [[BranchViewController alloc] initWithCommitHistoryList:searchResult repository:repository branch:branch];
    [self.navigationController pushViewController:searchResultController animated:YES];
                        
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)aSearchBar {
    letUserSelectCells = NO;
    self.searchBar = aSearchBar;
}

@end
