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
#import "Commit.h"
#import "IssueRootViewController.h"
#import <QuartzCore/QuartzCore.h>

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
@synthesize allEvents;

-(id) initWithAllEvents {
    self = [super initWithNibName:@"EventTableViewController" bundle:nil];
    if (self) {
        self.tabBarItem = [[UITabBarItem alloc]initWithTabBarSystemItem:UITabBarSystemItemFeatured tag:0];
        if ([Settings sharedInstance].isUsernameSet) {
            NSString *newBaseUrl = [NSString stringWithFormat:@"https://api.github.com/users/%@/received_events", [Settings sharedInstance].username];
            if (![newBaseUrl isEqualToString:self.baseUrl]) {
                self.baseUrl = newBaseUrl;
            }
        } else {
            self.baseUrl = @"https://api.github.com/events";
        }
        self.allEvents = YES;
        self.eventHistory = [[HistoryList alloc] init];
        self.isLoading = NO;
        self.complete = NO;
        self.pagesLoaded = 0;
        self.cachedHeights = [[NSCache alloc] init];
        
        [[Settings sharedInstance] addObserver:self forKeyPath:@"username" options:NSKeyValueObservingOptionOld  context:nil];
    }
    return self;
}

- (id)initWithRepository:(Repository *)aRepository {
    self = [super initWithNibName:@"EventTableViewController" bundle:nil];
    if (self) {
        self.repository = aRepository;
        self.baseUrl = [NSString stringWithFormat:@"https://api.github.com/repos/%@/events", self.repository.fullName];
        self.eventHistory = [[HistoryList alloc] init];
        self.isLoading = NO;
        self.complete = NO;
        self.pagesLoaded = 0;
        self.allEvents = NO;
        self.cachedHeights = [[NSCache alloc] init];
    }
    return self;
}

-(id)initWithUrl:(NSString*)url {
    self = [super initWithNibName:@"EventTableViewController" bundle:nil];
    if (self) {
        self.baseUrl = url;
        self.eventHistory = [[HistoryList alloc] init];
        self.isLoading = NO;
        self.complete = NO;
        self.pagesLoaded = 0;
        self.allEvents = NO;
        self.cachedHeights = [[NSCache alloc] init];
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

    self.navigationController.navigationBar.hidden = self.allEvents;
    
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
    [self.cachedHeights removeAllObjects];
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
    UILabel* repositoryLabel = nil;
    UILabel* timeLabel = nil;
    
    NSArray* objectsForDate = [eventHistory objectsForDate:date];
    GithubEvent* event = nil;
    if (objectsForDate.count > indexPath.row) {
        event = [objectsForDate objectAtIndex:indexPath.row];
    }
    
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

        repositoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(57.0f, 2.0f, 200.0f, 18.0f)];
        repositoryLabel.font = [UIFont systemFontOfSize:14.0f];
        repositoryLabel.textColor = [UIColor grayColor];
        repositoryLabel.numberOfLines = 1;
        repositoryLabel.tag = 3;

        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.tableView.bounds.size.width - 60.0f, 2.0f, 50.0f, 18.0f)];
        timeLabel.font = [UIFont systemFontOfSize:11.0f];
        timeLabel.textColor = [UIColor grayColor];
        timeLabel.numberOfLines = 1;
        timeLabel.tag = 4;

        [cell.contentView addSubview:imageView];
        [cell.contentView addSubview:label];
        [cell.contentView addSubview:repositoryLabel];
        [cell.contentView addSubview:timeLabel];
    } else {
        imageView = (UIImageView*)[cell.contentView viewWithTag:1];
        label = (UILabel*)[cell.contentView viewWithTag:2];
        repositoryLabel = (UILabel*)[cell.contentView viewWithTag:3];
        timeLabel = (UILabel*)[cell.contentView viewWithTag:4];
    }

    if ([event isKindOfClass:[PushEvent class]]) {
        [cell bindPushEvent:(PushEvent*)event];
    } else if ([event isKindOfClass:[PullRequestEvent class]]) {
        [cell bindPullRequestEvent:(PullRequestEvent*)event];
    } else if ([event isKindOfClass:[CommitCommentEvent class]]) {
        [cell bindCommitCommentEvent:(CommitCommentEvent*)event];
    } else if ([event isKindOfClass:[CreateRepositoryEvent class]]) {
        [cell bindGithubEvent:event];
        if (self.repository == nil) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    } else if ([event isKindOfClass:[ForkEvent class]]) {
        [cell bindGithubEvent:event];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if ([event isKindOfClass:[PullRequestReviewCommentEvent class]]) {
        [cell bindPullRequestReviewCommentEvent:(PullRequestReviewCommentEvent*)event];
    } else if ([event isKindOfClass:[IssueCommentEvent class]]) {
        [cell bindIssueCommentEvent:(IssueCommentEvent*)event];
    } else if ([event isKindOfClass:[IssuesEvent class]]) {
        [cell bindIssuesEvent:(IssuesEvent*)event];
    } else if (event != nil) {
        [cell bindGithubEvent:event];
    }
    timeLabel.text =
        [NSDateFormatter localizedStringFromDate:event.date
                                       dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    
    if (self.repository == nil) {
        repositoryLabel.hidden = NO;
        repositoryLabel.text = event.repository.fullName;
    } else {
        repositoryLabel.hidden = YES;
        repositoryLabel.text = nil;
    }

    CGFloat width = self.tableView.bounds.size.width;

    repositoryLabel.frame = CGRectMake(55.0f, 2.0f, width - 117.0f , 18.0f);
    timeLabel.frame = CGRectMake(self.tableView.bounds.size.width - 60.0f, 2.0f, 50.0f, 18.0f);

    NSString *key = event.text;
    NSNumber *height = [self.cachedHeights objectForKey:key];
    if (height == nil) {
        CGSize size = [label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(width - 97.0f, 200.0f) lineBreakMode:UILineBreakModeWordWrap];
        height = [NSNumber numberWithFloat:size.height];
        @try {
            [self.cachedHeights setValue:height forKey:key];
        } @catch (NSException *e) {
            // Simply ignore it
            NSLog(@"Got NSException!");
        }
    }
    label.frame = CGRectMake(55.0f, 20.0f, width - 97.0f, [height floatValue]);
    
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
    NSString *key = event.text;
    NSNumber *height = [self.cachedHeights objectForKey:key];
    if (height) {
        CGFloat cachedHeight = [height floatValue];
        cachedHeight += 18.0f;
        cachedHeight = cachedHeight > 55.0f ? cachedHeight : 55.0f;
        return cachedHeight;
    }
    CGSize size = [event.text sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(tableView.frame.size.width - 97.0f, 200.0f) lineBreakMode:UILineBreakModeWordWrap];
    CGFloat labelHeight = size.height + 4;
    [self.cachedHeights setObject:[NSNumber numberWithFloat:labelHeight] forKey:key];
    labelHeight += 18.0f;
    labelHeight = labelHeight > 55.0f ? labelHeight : 55.0f;
    return labelHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* date = [eventHistory.dates objectAtIndex:indexPath.section];
    GithubEvent* event = [[eventHistory objectsForDate:date] objectAtIndex:indexPath.row];
    if ([event isKindOfClass:[PushEvent class]]) {
        PushEvent* pushEvent = (PushEvent*)event;
        self.navigationController.navigationBarHidden = NO;
        if (pushEvent.commits.count > 0) {
            if (pushEvent.commits.count == 1) {
                CommitViewController* commitViewController = [[CommitViewController alloc] initWithCommit:pushEvent.commits.lastCommit repository:pushEvent.repository];
                [self.navigationController pushViewController:commitViewController animated:YES];
            } else {
                BranchViewController* branchViewController = [[BranchViewController alloc] initWithCommitHistoryList:pushEvent.commits repository:pushEvent.repository branch:nil];
                [self.navigationController pushViewController:branchViewController animated:YES];
            }
        }
    } else if ([event isKindOfClass:[PullRequestEvent class]]) {
        PullRequest *pullRequest = [(PullRequestEvent*)event pullRequest];
        // This pull request is only the payload of the event. It may currently be in another state, so it has to be reloaded
        [[NetworkProxy sharedInstance] loadStringFromURL:pullRequest.selfUrl block:^(int statusCode, NSDictionary *aHeaderFields, id data) {
            if (statusCode == 200) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.navigationController.navigationBarHidden = NO;
                    PullRequest *currentPullRequest = [[PullRequest alloc] initWithJSONObject:data repository:pullRequest.repository];
                    PullRequestRootViewController *pullRequestRootViewController = [[PullRequestRootViewController alloc] initWithPullRequest:currentPullRequest];
                    [self.navigationController pushViewController:pullRequestRootViewController animated:YES];
                });
            }
        }];
    } else if ([event isKindOfClass:[IssueCommentEvent class]]) {
        [[NetworkProxy sharedInstance] loadStringFromURL:((IssueCommentEvent*)event).selfUrl block:^(int statusCode, NSDictionary *aHeaderFields, id data) {
            if (statusCode == 200) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.navigationController.navigationBarHidden = NO;
                    Issue *issue = [[Issue alloc] initWithJSONObject:data repository:event.repository];
                    IssueRootViewController *issueRootViewController = [[IssueRootViewController alloc] initWithIssue:issue];
                    [self.navigationController pushViewController:issueRootViewController animated:YES];
                });
            }
        }];
    } else if ([event isKindOfClass:[IssuesEvent class]]) {
        [[NetworkProxy sharedInstance] loadStringFromURL:((IssuesEvent*)event).selfUrl block:^(int statusCode, NSDictionary *aHeaderFields, id data) {
            if (statusCode == 200) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.navigationController.navigationBarHidden = NO;
                    Issue *issue = [[Issue alloc] initWithJSONObject:data repository:event.repository];
                    IssueRootViewController *issueRootViewController = [[IssueRootViewController alloc] initWithIssue:issue];
                    [self.navigationController pushViewController:issueRootViewController animated:YES];
                });
            }
        }];
    } else if ([event isKindOfClass:[CommitCommentEvent class]]) {
        NSString *url = [NSString stringWithFormat:@"https://api.github.com/repos/%@/commits/%@", event.repository.fullName, [(CommitCommentEvent*)event commitSha]];
        [[NetworkProxy sharedInstance] loadStringFromURL:url block:^(int statusCode, NSDictionary *aHeaderFields, id data) {
            if (statusCode == 200) {
                Commit *commit = [[Commit alloc] initWithJSONObject:data repository:event.repository];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.navigationController.navigationBarHidden = NO;
                    CommitViewController *commitViewController = [[CommitViewController alloc] initWithCommit:commit repository:event.repository];
                    [self.navigationController pushViewController:commitViewController animated:YES];
                });
            }
        }];
    } else if ([event isKindOfClass:[PullRequestReviewCommentEvent class]]) {
        NSString *url = [NSString stringWithFormat:@"https://api.github.com/repos/%@/commits/%@", event.repository.fullName, [(CommitCommentEvent*)event commitSha]];
        [[NetworkProxy sharedInstance] loadStringFromURL:url block:^(int statusCode, NSDictionary *aHeaderFields, id data) {
            if (statusCode == 200) {
                Commit *commit = [[Commit alloc] initWithJSONObject:data repository:event.repository];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.navigationController.navigationBarHidden = NO;
                    CommitViewController *commitViewController = [[CommitViewController alloc] initWithCommit:commit repository:event.repository];
                    [self.navigationController pushViewController:commitViewController animated:YES];
                });
            }
        }];
    } else if (([event isKindOfClass:[CreateRepositoryEvent class]] && self.repository == nil)
                || [event isKindOfClass:[ForkEvent class]]) {
        self.navigationController.navigationBarHidden = NO;
        UIRepositoryRootViewController *repositoryRootViewController = [[UIRepositoryRootViewController alloc] initWithRepository:event.repository];
        [self.navigationController pushViewController:repositoryRootViewController animated:YES];
    }
    
    
}


-(void)loadEvents {
    if (!isLoading && !complete) {
        NSString* url = [NSString stringWithFormat:@"%@?page=%d", self.baseUrl, pagesLoaded + 1];
        isLoading = YES;
        [[NetworkProxy sharedInstance] loadStringFromURL:url block:^(int statusCode, NSDictionary* headerFields, id data) {
            [self reloadDidFinish];
            if (statusCode == 200) {
                NSArray* eventArray = (NSArray*)data;
                if (eventArray.count == 0) {
                    self.complete = YES;
                } else {
                    for (NSDictionary* event in eventArray) {
                        GithubEvent* eventObject = [EventFactory createEventFromJsonObject:event];
                        if (eventObject != nil) {
                            [eventHistory addObject:eventObject date:eventObject.date primaryKey:eventObject.primaryKey];                        
                        }
                    }
                    pagesLoaded++;
                }
                dispatch_async(dispatch_get_main_queue(), ^() {
                    [self.tableView reloadData];
                });
            }
            isLoading = NO;
        }
         errorBlock:^(NSError *error) {
             self.isLoading = NO;
             [self reloadDidFinish];
             UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network access failed!", @"Error message alert view") message:[error localizedDescription] delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel Button") otherButtonTitles:nil];
             [alertView show];
         }];
    }    
}

-(void)reload {
    self.pagesLoaded = 0;
    [self loadEvents];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    self.eventHistory = [[HistoryList alloc] init];
    [self.tableView reloadData];
    self.pagesLoaded = 0;
    self.complete = NO;
    if ([Settings sharedInstance].isUsernameSet) {
        NSString *newBaseUrl = [NSString stringWithFormat:@"https://api.github.com/users/%@/received_events", [Settings sharedInstance].username];
        if (![newBaseUrl isEqualToString:self.baseUrl]) {
            self.baseUrl = newBaseUrl;
        }
    } else {
        self.baseUrl = @"https://api.github.com/events";
    }
}
@end
