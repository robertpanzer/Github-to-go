//
//  GithubNotificationTableViewController.h
//  Hub To Go
//
//  Created by Robert Panzer on 10.02.13.
//
//

#import <UIKit/UIKit.h>
#import "PullToRefreshTableViewController.h"
#import "Repository.h"

@interface GithubNotificationTableViewController : PullToRefreshTableViewController

@property(strong, nonatomic) IBOutlet UITableViewCell* loadNextTableViewCell;

- (id)initWithNotificationsAll:(BOOL)all participating:(BOOL)participating;

- (id)initWithNotificationsForRepository:(Repository*)repository all:(BOOL)all participating:(BOOL)participating;

@end
