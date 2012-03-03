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
#import "BranchViewController.h"

@interface EventTableViewController()

-(void) loadEvents;

@end

@implementation EventTableViewController;

@synthesize repository;
@synthesize eventHistory;
@synthesize complete;
@synthesize loadNextTableViewCell;
@synthesize isLoading;
@synthesize pagesLoaded;

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
        loadNextLabel.text = NSLocalizedString(@"Loading more commits...", @"Event list loading More entries");

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
    
    if (pagesLoaded == 0) {
        [self loadEvents];
    }
        
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

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
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
    } else {
        [cell bindGithubEvent:event];
    }
    
    CGFloat width = self.tableView.frame.size.width;

    CGSize size = [label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(width - 97.0f, 200.0f) lineBreakMode:UILineBreakModeWordWrap];
    label.frame = CGRectMake(55.0f, 2.0f, width - 97.0f, size.height);
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString* date = [eventHistory.dates objectAtIndex:section];
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
        if (pushEvent.commits.count == 1) {
            CommitViewController* commitViewController = [[CommitViewController alloc] initWithCommit:pushEvent.commits.lastCommit repository:self.repository];
            [self.navigationController pushViewController:commitViewController animated:YES];
        } else {
            BranchViewController* branchViewController = [[BranchViewController alloc] initWithCommitHistoryList:pushEvent.commits repository:self.repository branch:nil];
            [self.navigationController pushViewController:branchViewController animated:YES];
        }
    }
    
    
}


-(void)loadEvents {
    if (!isLoading && !complete) {
        NSString* url = [NSString stringWithFormat:@"https://api.github.com/repos/%@/events?page=%d", repository.fullName, pagesLoaded + 1];
        isLoading = YES;
        [[NetworkProxy sharedInstance] loadStringFromURL:url block:^(int statusCode, NSDictionary* headerFields, id data) {
            if (statusCode == 200) {
                NSArray* eventArray = (NSArray*)data;
                if (eventArray.count == 0) {
                    self.complete = YES;
                } else {
                    for (NSDictionary* event in eventArray) {
                        GithubEvent* eventObject = [EventFactory createEventFromJsonObject:event];
                        [eventHistory addObject:eventObject date:eventObject.date primaryKey:nil];
                    }
                    pagesLoaded++;
                }
                isLoading = NO;
                [self.tableView reloadData];
            }
        }];
    }    
}
@end
