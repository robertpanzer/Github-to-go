//
//  GithubNotificationTableViewController.m
//  Hub To Go
//
//  Created by Robert Panzer on 10.02.13.
//
//

#import "GithubNotificationTableViewController.h"
#import "GithubNotification.h"
#import "Settings.h"
#import "NetworkProxy.h"
#import "HistoryList.h"
#import "IssueRootViewController.h"
#import "PullRequestRootViewController.h"
#import "CommitViewController.h"
#import "QuartzCore/QuartzCore.h"

@interface GithubNotificationTableViewController ()

@property(strong, nonatomic) HistoryList* notificationHistory;
@property int pagesLoaded;
@property BOOL complete;
@property BOOL isLoading;
@property (strong, nonatomic) NSString* url;
@property (strong, nonatomic) NSString *lastModified;
@property (strong, nonatomic) NSCache *cachedHeights;


-(GithubNotification*)notificationAtIndexPath:(NSIndexPath*)indexPath;
-(void) updateUnreadMessagesBadge;

@end

static NSString *kTypeIssue = @"Issue";
static NSString *kTypePullRequest = @"PullRequest";
static NSString *kTypeCommit = @"Commit";

static NSSet *knownTypes;

static UIColor *unreadColor, *readColor;

@implementation GithubNotificationTableViewController

+(void)initialize {
    knownTypes = [NSSet setWithArray:@[kTypeIssue, kTypePullRequest, kTypeCommit]];
    unreadColor = [UIColor greenColor];
    readColor = [UIColor grayColor];
}

- (id)initWithNotificationsAll:(BOOL)all participating:(BOOL)participating
{
    self = [super initWithNibName:@"GithubNotificationTableViewController" bundle:nil];
    if (self) {
        _isLoading = NO;
        _complete = NO;
        _notificationHistory = [[HistoryList alloc] init];
        _url = [NSString stringWithFormat:@"https://api.github.com/notifications?all=%@&participating=%@",
                all ? @"true" : @"false",
                participating ? @"true" : @"false"];
        _cachedHeights = [[NSCache alloc] init];
        [[Settings sharedInstance] addObserver:self forKeyPath:@"username" options:NSKeyValueObservingOptionOld  context:nil];

    }
    return self;
}

- (id)initWithNotificationsForRepository:(Repository*)repository all:(BOOL)all participating:(BOOL)participating {
    self = [super initWithNibName:@"GithubNotificationTableViewController" bundle:nil];
    if (self) {
        _isLoading = NO;
        _complete = NO;
        _notificationHistory = [[HistoryList alloc] init];
        _url = [NSString stringWithFormat:@"https://api.github.com/repos/%@/notifications?all=%@&participating=%@",
                repository.fullName,
                all ? @"true" : @"false",
                participating ? @"true" : @"false"];
        _cachedHeights = [[NSCache alloc] init];
        [[Settings sharedInstance] addObserver:self forKeyPath:@"username" options:NSKeyValueObservingOptionOld  context:nil];
        
    }
    return self;
}


- (void)dealloc
{
    [[Settings sharedInstance] removeObserver:self forKeyPath:@"username"];
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    UILabel* loadNextLabel = (UILabel*)[self.loadNextTableViewCell.contentView viewWithTag:2];
    loadNextLabel.text = NSLocalizedString(@"Loading more notifications...", @"Notification list loading More entries");
}

-(void) viewDidUnload {
    self.loadNextTableViewCell = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.pagesLoaded == 0) {
        [self loadEvents];
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.notificationHistory.dates.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString* date = [self.notificationHistory.dates objectAtIndex:section];
    
    int entriesCount = [self.notificationHistory objectsForDate:date].count;
//    if (section == self.notificationHistory.dates.count - 1 && !self.complete) {
//        return entriesCount + 1;
//    } else {
        return entriesCount;
//    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* date = [self.notificationHistory.dates objectAtIndex:indexPath.section];
    

    if (indexPath.section == self.notificationHistory.dates.count - 1 && indexPath.row == [self.notificationHistory objectsForDate:date].count) {
        [self loadEvents];
        return self.loadNextTableViewCell;
    }

    UILabel *label = nil;
    UILabel *repositoryLabel = nil;
    UILabel *timeLabel = nil;
    UILabel *typeLabel = nil;
    
    static NSString *CellIdentifier = @"NotificationCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

        typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(4.0f, 13.0f, 42.0f, 18.0f)];

        typeLabel.backgroundColor = [UIColor darkGrayColor];
        typeLabel.textColor = [UIColor whiteColor];
        typeLabel.font = [UIFont boldSystemFontOfSize:11.0f];
        typeLabel.textAlignment = UITextAlignmentCenter;
        typeLabel.tag = 42;
        typeLabel.layer.cornerRadius = 5;
        typeLabel.opaque = NO;
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(57.0f, 2.0f, 0.0f, 0.0f)];
        label.font = [UIFont systemFontOfSize:14.0f];
        label.numberOfLines = 0;
        label.lineBreakMode = UILineBreakModeWordWrap;
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
        
        [cell.contentView addSubview:label];
        [cell.contentView addSubview:repositoryLabel];
        [cell.contentView addSubview:timeLabel];
        [cell.contentView addSubview:typeLabel];
    } else {
        typeLabel = (UILabel*)[cell.contentView viewWithTag:42];
        label = (UILabel*)[cell.contentView viewWithTag:2];
        repositoryLabel = (UILabel*)[cell.contentView viewWithTag:3];
        timeLabel = (UILabel*)[cell.contentView viewWithTag:4];
    }

    GithubNotification *notification = [self notificationAtIndexPath:indexPath];
    
    timeLabel.text = [NSDateFormatter localizedStringFromDate:notification.updatedAt
                                                    dateStyle:NSDateFormatterNoStyle
                                                    timeStyle:NSDateFormatterShortStyle];
    if ([notification.type isEqualToString:@"PullRequest"]) {
        typeLabel.text = @"PR";
    } else {
        typeLabel.text = notification.type;
    }

    typeLabel.backgroundColor = notification.unread ? unreadColor : readColor;

    repositoryLabel.text = notification.repository.fullName;
    CGFloat width = self.tableView.bounds.size.width;

    label.text = notification.title;
    NSString *key = notification.title;
    NSNumber *height = [self.cachedHeights objectForKey:key];
    if (height == nil) {
        CGSize size = [label.text sizeWithFont:label.font
                             constrainedToSize:CGSizeMake(width - 97.0f, 200.0f)
                                 lineBreakMode:UILineBreakModeWordWrap];
        height = [NSNumber numberWithFloat:size.height];
        @try {
            [self.cachedHeights setValue:height forKey:key];
        } @catch (NSException *e) {
            // Simply ignore it
            NSLog(@"Got NSException!");
        }
    }
    label.frame = CGRectMake(55.0f, 20.0f, width - 97.0f, [height floatValue]);
    cell.accessoryType = [knownTypes containsObject:notification.type] ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString* date = [self.notificationHistory stringFromInternalDate:self.notificationHistory.dates[section]];
    return date;
}


#pragma mark - Table view delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* date = [self.notificationHistory.dates objectAtIndex:indexPath.section];
    NSArray* objectsForDate = [self.notificationHistory objectsForDate:date];
    if (indexPath.row == objectsForDate.count) {
        return 55.0f;
    }
    GithubNotification* notification = [objectsForDate objectAtIndex:indexPath.row] ;
    NSString *key = notification.title;
    NSNumber *height = [self.cachedHeights objectForKey:key];
    if (height) {
        CGFloat cachedHeight = [height floatValue];
        cachedHeight += 18.0f;
        cachedHeight = cachedHeight > 55.0f ? cachedHeight : 55.0f;
        return cachedHeight;
    }
    CGSize size = [notification.title sizeWithFont:[UIFont systemFontOfSize:14.0f]
                          constrainedToSize:CGSizeMake(tableView.frame.size.width - 97.0f, 200.0f)
                              lineBreakMode:UILineBreakModeWordWrap];
    CGFloat labelHeight = size.height + 4;
    [self.cachedHeights setObject:[NSNumber numberWithFloat:labelHeight]
                           forKey:key];
    labelHeight += 18.0f;
    labelHeight = labelHeight > 55.0f ? labelHeight : 55.0f;
    return labelHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GithubNotification *notification = [self notificationAtIndexPath:indexPath];

    notification.unread = NO;
    [self.tableView reloadData];

    Repository* repo = notification.repository;
    if ([kTypeIssue isEqual:notification.type]) {
        [[NetworkProxy sharedInstance] loadStringFromURL:notification.url block:^(int statusCode, NSDictionary *aHeaderFields, id data) {
            if (statusCode == 200) {
                NSDictionary *jsonDictionary = (NSDictionary*)data;
                Issue *issue = [[Issue alloc] initWithJSONObject:jsonDictionary repository:repo];
                dispatch_async(dispatch_get_main_queue(), ^{
                    IssueRootViewController *vc = [[IssueRootViewController alloc] initWithIssue:issue];
                    [self.navigationController pushViewController:vc animated:YES];
                    self.navigationController.navigationBarHidden = NO;
                });
            }
        }];
    } else if ([kTypePullRequest isEqual:notification.type]) {
        [[NetworkProxy sharedInstance] loadStringFromURL:notification.url block:^(int statusCode, NSDictionary *aHeaderFields, id data) {
            if (statusCode == 200) {
                NSDictionary *jsonDictionary = (NSDictionary*)data;
                PullRequest *pullRequest = [[PullRequest alloc] initWithJSONObject:jsonDictionary repository:repo];
                dispatch_async(dispatch_get_main_queue(), ^{
                    PullRequestRootViewController *vc = [[PullRequestRootViewController alloc] initWithPullRequest:pullRequest];
                    [self.navigationController pushViewController:vc animated:YES];
                    self.navigationController.navigationBarHidden = NO;
                });
            }
        }];
    } else if ([kTypeCommit isEqual:notification.type]) {
        [[NetworkProxy sharedInstance] loadStringFromURL:notification.url block:^(int statusCode, NSDictionary *aHeaderFields, id data) {
            if (statusCode == 200) {
                NSDictionary *jsonDictionary = (NSDictionary*)data;
                Commit *commit = [[Commit alloc] initWithJSONObject:jsonDictionary repository:repo];
                dispatch_async(dispatch_get_main_queue(), ^{
                    CommitViewController *vc = [[CommitViewController alloc] initWithCommit:commit repository:repo];
                    [self.navigationController pushViewController:vc animated:YES];
                    self.navigationController.navigationBarHidden = NO;
                });
            }
        }];
    }
    
    // mark as read
    NSString *url = [NSString stringWithFormat:@"https://api.github.com/notifications/threads/%@", notification.id];
    [[NetworkProxy sharedInstance] sendData:@{@"unread": @NO}
                                      ToUrl:url
                                       verb:@"PATCH" block:^(int statusCode, NSDictionary *aHeaderFields, id data) {
                                           if (statusCode != 205) {
                                                // TODO: Notify user of failure?
                                               NSLog(@"Marking notification as read failed with status code %d", statusCode);
                                           }
                                       } errorBlock:nil];
    notification.unread = NO;
    [self updateUnreadMessagesBadge];

}

-(void)reload {
    self.pagesLoaded = 0;
    [self loadEvents];
    
    self.tabBarItem.badgeValue = @"42";
}


-(void)loadEvents {
    if (!self.isLoading && !self.complete) {
        self.isLoading = YES;
        NSMutableDictionary* headerFields = [NSMutableDictionary dictionary];
        if (self.lastModified != nil) {
            headerFields[@"If-Modified-Since"] = self.lastModified;
        }
        [[NetworkProxy sharedInstance] loadStringFromURL:self.url
                                                    verb:@"GET"
                                            headerFields:headerFields
                                                   block:^(int statusCode, NSDictionary* headerFields, id data) {
                                                       self.lastModified = headerFields[@"Last-Modified"];
                                                       if (statusCode == 200) {
                                                           NSArray* notificationArray = (NSArray*)data;
                                                           if (notificationArray.count == 0) {
                                                               self.complete = YES;
                                                           } else {
                                                               for (NSDictionary* notification in notificationArray) {
                                                                   GithubNotification* notificationObject = [[GithubNotification alloc] initWithJsonObject:notification];
                                                                   if (notificationObject != nil) {
                                                                       [self.notificationHistory addObject:notificationObject
                                                                                                      date:notificationObject.updatedAt
                                                                                                primaryKey:notificationObject.id];
                                                                   }
                                                               }
                                                               self.pagesLoaded++;
                                                           }
                                                           dispatch_async(dispatch_get_main_queue(), ^() {
                                                               [self.tableView reloadData];
                                                           });
                                                       } else {
                                                           NSLog(@"Status code %d", statusCode);
                                                       }
                                                       self.isLoading = NO;
                                                       
                                                       [self updateUnreadMessagesBadge];
                                                       [self reloadDidFinish];
                                                       
                                                   }
                                              errorBlock:^(NSError *error) {
                                                  self.isLoading = NO;
                                                  [self reloadDidFinish];
                                                  UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network access failed!", @"Error message alert view") message:[error localizedDescription] delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel Button") otherButtonTitles:nil];
                                                  [alertView show];
                                              }];
    } else {
        [self reloadDidFinish];
    }
}

-(void) updateUnreadMessagesBadge {
    int unreadNotifications = 0;
    for (GithubNotification *notification in self.notificationHistory.objectsByPrimaryKey.objectEnumerator) {
        if (notification.unread) {
            unreadNotifications++;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (unreadNotifications == 0) {
            self.parentViewController.tabBarItem.badgeValue = nil;
        } else {
            self.parentViewController.tabBarItem.badgeValue = [[NSNumber numberWithInt:unreadNotifications] stringValue];
        }
    });
}

-(GithubNotification*)notificationAtIndexPath:(NSIndexPath*)indexPath
{
    NSString* date = [self.notificationHistory.dates objectAtIndex:indexPath.section];
    NSArray* objectsForDate = [self.notificationHistory objectsForDate:date];
    GithubNotification* notification = [objectsForDate objectAtIndex:indexPath.row];
    return notification;
}

@end
