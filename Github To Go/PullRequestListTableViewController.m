//
//  PullRequestListTableViewController.m
//  Github To Go
//
//  Created by Robert Panzer on 09.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PullRequestListTableViewController.h"
#import "PullRequest.h"
#import "NetworkProxy.h"
#import "PullRequestRootViewController.h"

@interface PullRequestListTableViewController ()

-(void)loadPullRequests;

@end

@implementation PullRequestListTableViewController

@synthesize repository;
@synthesize pullRequests;

- (id)initWithRepository:(Repository*)aRepository
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        // Custom initialization
        self.repository = aRepository;
        self.pullRequests = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (pullRequests.count == 0) {
        [self loadPullRequests];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.pullRequests = nil;
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
    return [self.pullRequests count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.detailTextLabel.numberOfLines = 2;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13.0f];
        cell.textLabel.font = [UIFont systemFontOfSize:13.0f];
    }
    // Configure the cell...
    PullRequest* pullRequest = ((PullRequest*)[self.pullRequests objectAtIndex:indexPath.row]);
    cell.textLabel.text = [pullRequest.number description];
    cell.detailTextLabel.text = pullRequest.title;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PullRequest* pullRequest = [pullRequests objectAtIndex:indexPath.row];
    PullRequestRootViewController* pullRequestRootViewController = [[PullRequestRootViewController alloc] initWithPullRequest:pullRequest];
    [self.navigationController pushViewController:pullRequestRootViewController animated:YES];
}


-(void)loadPullRequests {
    NSString* url = [NSString stringWithFormat:@"https://api.github.com/repos/%@/pulls", repository.fullName];
    [[NetworkProxy sharedInstance] loadStringFromURL:url block:^(int statusCode, NSDictionary* headerFields, id data) {
        if (statusCode == 200) {
            if ([data isKindOfClass:[NSDictionary class]]) {
                PullRequest* pullRequest = [[PullRequest alloc] initWithJSONObject:data repository:self.repository];
                [self.pullRequests addObject:pullRequest];
            } else {
                NSArray* pullRequestArray = (NSArray*)data;
                for (NSDictionary* jsonObject in pullRequestArray) {
                    PullRequest* pullRequest = [[PullRequest alloc] initWithJSONObject:jsonObject repository:self.repository];
                    [self.pullRequests addObject:pullRequest];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^() {
                [self.tableView reloadData];
            });
        }
    }];
}


@end
