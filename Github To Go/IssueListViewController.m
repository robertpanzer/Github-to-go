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

@property(strong, nonatomic) NSString *url;

@end

@implementation IssueListViewController

@synthesize repository;
@synthesize issues;
@synthesize url;

- (id)initWithRepository:(Repository*)aRepository
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        // Custom initialization
        self.repository = aRepository;
        self.url = [NSString stringWithFormat:@"https://api.github.com/repos/%@/issues", repository.fullName];
        self.issues = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (issues.count == 0) {
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
    return issues.count;
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
    [[NetworkProxy sharedInstance] loadStringFromURL:self.url block:^(int statusCode, NSDictionary* headerFields, id data) {
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
