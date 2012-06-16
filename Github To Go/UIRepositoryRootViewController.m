//
//  UIRepositoryRootViewController.m
//  Github To Go
//
//  Created by Robert Panzer on 29.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIRepositoryRootViewController.h"
#import "RepositoryViewController.h"
#import "RepositoryStorage.h"
#import "NetworkProxy.h"

static NSString* WatchRepo;
static NSString* StopWatchingRepo;

static NSArray* actionSheetTitles;

@implementation UIRepositoryRootViewController

@synthesize repository;
@synthesize watched;

+(void) initialize {
    WatchRepo = NSLocalizedString(@"Watch Repository", @"Action Sheet Watch Repo");
    StopWatchingRepo = NSLocalizedString(@"Stop watching", @"Action Sheet Stop Watching");
    actionSheetTitles = [NSArray arrayWithObjects:WatchRepo, StopWatchingRepo, nil];
}

- (id)initWithRepository:(Repository*)aRepository
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.repository = aRepository;
        self.watched = [[RepositoryStorage sharedStorage] repositoryIsWatched:aRepository];
        
        UIViewController* repositoryViewController = [[RepositoryViewController alloc] initWithRepository:repository];
        UIViewController* branchesBrowserViewController = [[BranchesBrowserViewController alloc] initWithRepository:repository];
        UIViewController* eventTableViewController = [[EventTableViewController alloc] initWithRepository:repository];
        UIViewController* pullRequestTableViewController = [[PullRequestListTableViewController alloc] initWithRepository:repository];
        UIViewController* issueListViewController = [[IssueListViewController alloc] initWithRepository:repository];

        self.titles = [NSArray arrayWithObjects:@"Events", @"Branches", @"Info", @"Pulls", @"Issues", nil];
        [self addChildViewController:eventTableViewController];
        [self addChildViewController:branchesBrowserViewController];
        [self addChildViewController:repositoryViewController];
        [self addChildViewController:pullRequestTableViewController];
        [self addChildViewController:issueListViewController];
        
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = repository.fullName;
    
    if ([[RepositoryStorage sharedStorage].ownRepositories objectForKey:self.repository.fullName] == nil) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActionSheet)];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


-(void)showActionSheet {
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel Button") destructiveButtonTitle:nil otherButtonTitles:nil];
    if (![[RepositoryStorage sharedStorage] repositoryIsWatched:repository]){
        [actionSheet addButtonWithTitle:WatchRepo];
    } else {
        [actionSheet addButtonWithTitle:StopWatchingRepo];
    }
    
    [actionSheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    NSString* titleClicked = [actionSheet buttonTitleAtIndex:buttonIndex];
    NSString* url = [NSString stringWithFormat:@"https://api.github.com/user/watched/%@", repository.fullName];
    if ([WatchRepo isEqualToString:titleClicked]) {
        [[NetworkProxy sharedInstance] loadStringFromURL:url verb:@"PUT" block:^(int status, NSDictionary* headerFields, id data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == 204) {
                    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:titleClicked message:NSLocalizedString(@"Repository is being watched now", @"Alert View") delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [alertView show];
                } else {
                    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:titleClicked message:NSLocalizedString(@"Starting to watch repository failed", @"Alert view") delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [alertView show];
                }
            });
        } ];
    } else if ([StopWatchingRepo isEqualToString:titleClicked]) {
        [[NetworkProxy sharedInstance] loadStringFromURL:url verb:@"DELETE" block:^(int status, NSDictionary* headerFields, id data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == 204) {
                    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:titleClicked message:NSLocalizedString(@"Repository is no longer watched now", @"Alert view") delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [alertView show];
                } else {
                    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:titleClicked message:NSLocalizedString(@"Stopping to watch repository failed", @"Alert view") delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [alertView show];
                }
            });
        } ];
    }
}
@end
