//
//  EventTableViewController.m
//  Github To Go
//
//  Created by Robert Panzer on 09.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventTableViewController.h"
#import "NetworkProxy.h"
#import "GithubEvent.h"
#import "UITableViewCell+GithubEvent.h"
#import "CommitViewController.h"
#import "PullRequestRootViewController.h"
#import "Settings.h"
#import "UIRepositoryRootViewController.h"
#import "BranchViewController.h"

@interface EventTableViewController()

-(void) loadEvents;

@property(strong, nonatomic) NSString *baseUrl;

@end

@implementation EventTableViewController;

@synthesize repository;
@synthesize eventHistory;
@synthesize complete;
@synthesize loadNextTableViewCell;
@synthesize isLoading;
@synthesize pagesLoaded;
@synthesize baseUrl;

-(id) initWithAllEvents {
    self = [super initWithNibName:@"EventTableViewController" bundle:nil];
    if (self) {
        self.tabBarItem = [[UITabBarItem alloc]initWithTabBarSystemItem:UITabBarSystemItemFeatured tag:0];

        self.eventHistory = [[HistoryList alloc] init];
        self.isLoading = NO;
        self.complete = NO;
        self.pagesLoaded = 0;
    }
    return self;
}

- (id)initWithRepository:(Repository *)aRepository {
    self = [super initWithNibName:@"EventTableViewController" bundle:nil];
    if (self) {
        self.repository = aRepository;
        self.eventHistory = [[HistoryList alloc] init];
        self.isLoading = NO;
        self.complete = NO;
        self.pagesLoaded = 0;
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
    UILabel* loadNextLabel = (UILabel*)[self.loadNextTableViewCell.contentView viewWithTag:2];
        loadNextLabel.text = NSLocalizedString(@"Loading more events...", @"Event list loading More entries");
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.loadNextTableViewCell = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationController.navigationBar.hidden = (self.repository == nil);

    if (self.repository != nil) {
        self.baseUrl = [NSString stringWithFormat:@"https://api.github.com/repos/%@/events", repository.fullName];
    } else if ([Settings sharedInstance].isUsernameSet) {
        NSString *newBaseUrl = [NSString stringWithFormat:@"https://api.github.com/users/%@/received_events", [Settings sharedInstance].username];
        if (![newBaseUrl isEqualToString:self.baseUrl]) {
            self.baseUrl = newBaseUrl;
            self.eventHistory = [[HistoryList alloc] init];
            self.pagesLoaded = 0;
            self.complete = NO;
            [self loadEvents];
        }
    } else {
        self.baseUrl = @"https://api.github.com/events";
    }
    
    if (pagesLoaded == 0) {
        [self loadEvents];
    }
        
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return eventHistory.dates.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString* date = [eventHistory.dates objectAtIndex:section];
    
    int entriesCount = [eventHistory objectsForDate:date].count;
    if (section == eventHistory.dates.count - 1 && !self.complete) {
        return entriesCount + 1;
    } else {
        return entriesCount;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* date = [eventHistory.dates objectAtIndex:indexPath.section];

    if (indexPath.section == eventHistory.dates.count - 1 && indexPath.row == [eventHistory objectsForDate:date].count) {
        [self loadEvents];
        return self.loadNextTableViewCell;
    }

    static NSString *CellIdentifier = @"Cell";
    
    UIImageView* imageView = nil;
    UILabel* label = nil;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 55.0f, 55.0f)];
        label = [[UILabel alloc] initWithFrame:CGRectMake(57.0f, 2.0f, 0.0f, 0.0f)];
        label.font = [UIFont systemFontOfSize:14.0f];
        label.numberOfLines = 0;
        label.lineBreakMode = UILineBreakModeWordWrap;
        imageView.tag = 1;
        label.tag = 2;
        
        [cell.contentView addSubview:imageView];
        [cell.contentView addSubview:label];
    } else {
        imageView = (UIImageView*)[cell.contentView viewWithTag:1];
        label = (UILabel*)[cell.contentView viewWithTag:2];
    }
    GithubEvent* event = [[eventHistory objectsForDate:date] objectAtIndex:indexPath.row];

    if ([event isKindOfClass:[PushEvent class]]) {
        [cell bindPushEvent:(PushEvent*)event];
    } else if ([event isKindOfClass:[PullRequestEvent class]]) {
        [cell bindPullRequestEvent:(PullRequestEvent*)event];
    } else if ([event isKindOfClass:[CreateRepositoryEvent class]]) {
        [cell bindGithubEvent:event];
        if (self.repository == nil) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    } else if ([event isKindOfClass:[ForkEvent class]]) {
        [cell bindGithubEvent:event];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        [cell bindGithubEvent:event];
    }
    
    CGFloat width = self.tableView.frame.size.width;

    CGSize size = [label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(width - 97.0f, 200.0f) lineBreakMode:UILineBreakModeWordWrap];
    label.frame = CGRectMake(55.0f, 2.0f, width - 97.0f, size.height);
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString* date = [eventHistory stringFromInternalDate:[eventHistory.dates objectAtIndex:section]];
    return date;
}


#pragma mark - Table view delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* date = [eventHistory.dates objectAtIndex:indexPath.section];
    NSArray* objectsForDate = [eventHistory objectsForDate:date];
    if (indexPath.row == objectsForDate.count) {
        return 55.0f;
    }
    GithubEvent* event = [objectsForDate objectAtIndex:indexPath.row] ;
    CGSize size = [event.text sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(tableView.frame.size.width - 97.0f, 200.0f) lineBreakMode:UILineBreakModeWordWrap];
    CGFloat labelHeight = size.height + 4;
    return labelHeight > 55.0f ? labelHeight : 55.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* date = [eventHistory.dates objectAtIndex:indexPath.section];
    GithubEvent* event = [[eventHistory objectsForDate:date] objectAtIndex:indexPath.row];
    if ([event isKindOfClass:[PushEvent class]]) {
        PushEvent* pushEvent = (PushEvent*)event;
        if (pushEvent.commits.count > 0) {
            if (pushEvent.commits.count == 1) {
                CommitViewController* commitViewController = [[CommitViewController alloc] initWithCommit:pushEvent.commits.lastCommit repository:pushEvent.repository];
                [self.navigationController pushViewController:commitViewController animated:YES];
                self.navigationController.navigationBar.hidden = NO;
            } else {
                BranchViewController* branchViewController = [[BranchViewController alloc] initWithCommitHistoryList:pushEvent.commits repository:pushEvent.repository branch:nil];
                [self.navigationController pushViewController:branchViewController animated:YES];
                self.navigationController.navigationBar.hidden = NO;
            }
        }
    } else if ([event isKindOfClass:[PullRequestEvent class]]) {
        PullRequest *pullRequest = [(PullRequestEvent*)event pullRequest];
        // This pull request is only the payload of the event. It may currently be in another state, so it has to be reloaded
        [[NetworkProxy sharedInstance] loadStringFromURL:pullRequest.selfUrl block:^(int statusCode, NSDictionary *aHeaderFields, id data) {
            if (statusCode == 200) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    PullRequest *currentPullRequest = [[PullRequest alloc] initWithJSONObject:data repository:pullRequest.repository];
                    PullRequestRootViewController *pullRequestRootViewController = [[PullRequestRootViewController alloc] initWithPullRequest:currentPullRequest];
                    [self.navigationController pushViewController:pullRequestRootViewController animated:YES];
                });
            }
        }];
    } else if (([event isKindOfClass:[CreateRepositoryEvent class]] && self.repository == nil)
                || [event isKindOfClass:[ForkEvent class]]) {
        UIRepositoryRootViewController *repositoryRootViewController = [[UIRepositoryRootViewController alloc] initWithRepository:event.repository];
        [self.navigationController pushViewController:repositoryRootViewController animated:YES];
        self.navigationController.navigationBar.hidden = NO;
    }
    
    
}


-(void)loadEvents {
    if (!isLoading && !complete) {
        NSString* url = [NSString stringWithFormat:@"%@?page=%d", self.baseUrl, pagesLoaded + 1];
        isLoading = YES;
        [[NetworkProxy sharedInstance] loadStringFromURL:url block:^(int statusCode, NSDictionary* headerFields, id data) {
            if (statusCode == 200) {
                NSArray* eventArray = (NSArray*)data;
                if (eventArray.count == 0) {
                    self.complete = YES;
                } else {
                    for (NSDictionary* event in eventArray) {
                        GithubEvent* eventObject = [EventFactory createEventFromJsonObject:event];
                        [eventHistory addObject:eventObject date:eventObject.date primaryKey:eventObject.primaryKey];                        
                    }
                    pagesLoaded++;
                    dispatch_async(dispatch_get_main_queue(), ^() {
                        [self.tableView reloadData];
                    });
                }
                isLoading = NO;
            }
        }];
    }    
}

-(void)reload {
    self.pagesLoaded = 0;
    [self loadEvents];
}

@end
