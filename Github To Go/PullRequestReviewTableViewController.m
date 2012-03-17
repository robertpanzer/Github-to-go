//
//  PullRequestReviewTableViewController.m
//  Github To Go
//
//  Created by Robert Panzer on 14.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PullRequestReviewTableViewController.h"
#import "PullRequest.h"
#import "NetworkProxy.h"
#import "CommitFile.h"
#import "UITableViewCell+CommitFile.h"


@interface PullRequestReviewTableViewController ()

@end

@implementation PullRequestReviewTableViewController

@synthesize pullRequest;
@synthesize files;

- (id)initWithPullRequest:(PullRequest*)aPullRequest
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.pullRequest = aPullRequest;
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

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (files == nil) {
        
        NSString* url = [self.pullRequest.selfUrl stringByAppendingString:@"/files"];
        [[NetworkProxy sharedInstance] loadStringFromURL:url block:^(int statusCode, NSDictionary* headerFields, id data) {
            if (statusCode == 200) {
                NSArray* filesArray = (NSArray*)data;
                NSMutableArray* newFiles = [NSMutableArray array];
                for (NSDictionary* jsonObject in filesArray) {
                    CommitFile* commitFile = [[CommitFile alloc] initWithJSONObject:jsonObject commit:nil];
                    [newFiles addObject:commitFile];
                }
                self.files = newFiles;
                dispatch_async(dispatch_get_main_queue(), ^() {
                    [self.tableView reloadData];
                });
            }
        }];
    }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return files.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommitFile* commitFile = [self.files objectAtIndex:indexPath.row];
    UITableViewCell *cell = [UITableViewCell createCommitFileCellForTableView:self.tableView];
    [cell bindCommitFile:commitFile];
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
