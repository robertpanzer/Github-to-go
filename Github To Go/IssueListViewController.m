//
//  IssueListViewController.m
//  Hub To Go
//
//  Created by Robert Panzer on 22.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IssueListViewController.h"
#import "NetworkProxy.h"
#import "Issue.h"
#import "IssueRootViewController.h"

@interface IssueListViewController ()

@end

@implementation IssueListViewController


- (id)initWithRepository:(Repository*)aRepository
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        // Custom initialization
        _repository = aRepository;
        _issues = [NSMutableArray array];
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated {
    if (self.issues.count == 0) {
        [self reload];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
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
    return self.issues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.detailTextLabel.numberOfLines = 2;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13.0f];
        cell.textLabel.font = [UIFont systemFontOfSize:13.0f];
    }
    // Configure the cell...
    Issue* issue = ((Issue*)[self.issues objectAtIndex:indexPath.row]);
    cell.textLabel.text = [issue.number description];
    cell.detailTextLabel.text = issue.title;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Issue* issue = [self.issues objectAtIndex:indexPath.row];
    IssueRootViewController* issueViewController = [[IssueRootViewController alloc] initWithIssue:issue];
    [self.navigationController pushViewController:issueViewController animated:YES];
    
}

-(void)reload {
    [[NetworkProxy sharedInstance] loadStringFromURL:self.repository.issuesUrl block:^(int statusCode, NSDictionary* headerFields, id data) {
        if (statusCode == 200) {
            [self.issues removeAllObjects];
            if ([data isKindOfClass:[NSDictionary class]]) {
                Issue *issue = [[Issue alloc] initWithJSONObject:data repository:self.repository];
                [self.issues addObject:issue];
            } else {
                NSArray* issuesArray = (NSArray*)data;
                for (NSDictionary* jsonObject in issuesArray) {
                    Issue* issue = [[Issue alloc] initWithJSONObject:jsonObject repository:self.repository];
                    [self.issues addObject:issue];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^() {
                [self.tableView reloadData];
            });
        }
        [self reloadDidFinish];
    }];
}


@end
