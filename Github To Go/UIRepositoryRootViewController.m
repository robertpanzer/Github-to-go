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
@synthesize repositoryViewController;
@synthesize branchesBrowserViewController;
@synthesize headerView;  
@synthesize eventTableViewController;
@synthesize watched;

+(void) initialize {
    WatchRepo = @"Watch Repository";
    StopWatchingRepo = @"Stop watching";
    actionSheetTitles = [NSArray arrayWithObjects:WatchRepo, StopWatchingRepo, nil];
}

- (id)initWithRepository:(Repository*)aRepository
{
    self = [super initWithNibName:@"UIRepositoryRootViewController" bundle:nil];
    if (self) {
        // Custom initialization
        self.repository = aRepository;
        self.watched = [[RepositoryStorage sharedStorage] repositoryIsWatched:aRepository];
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
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = repository.fullName;
    
    repositoryViewController = [[RepositoryViewController alloc] initWithRepository:repository];
    branchesBrowserViewController = [[BranchesBrowserViewController alloc] initWithRepository:repository];
    eventTableViewController = [[EventTableViewController alloc] initWithRepository:repository];

    repositoryViewController.view.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    branchesBrowserViewController.view.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    eventTableViewController.view.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);

    [self.view addSubview:eventTableViewController.view];
    [self addChildViewController:eventTableViewController];
    eventTableViewController.tableView.tableHeaderView = self.headerView;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActionSheet)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.eventTableViewController = nil;
    self.branchesBrowserViewController = nil;
    self.repositoryViewController = nil;
    self.headerView = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


-(void)selectedSegmentChanged:(id)sender {
    UISegmentedControl* segmentedControl = sender;
    repositoryViewController.tableView.tableHeaderView = nil;
    branchesBrowserViewController.tableView.tableHeaderView = nil;
    eventTableViewController.tableView.tableHeaderView = nil;
    switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            [repositoryViewController removeFromParentViewController];
            [repositoryViewController.view removeFromSuperview];
            [branchesBrowserViewController removeFromParentViewController];
            [branchesBrowserViewController.view removeFromSuperview];
            [self addChildViewController:eventTableViewController];
            [self.view addSubview:eventTableViewController.view];
            eventTableViewController.tableView.tableHeaderView = self.headerView;
            break;
        case 1:
            [repositoryViewController removeFromParentViewController];
            [repositoryViewController.view removeFromSuperview];
            [eventTableViewController removeFromParentViewController];
            [eventTableViewController.view removeFromSuperview];
            [self addChildViewController:branchesBrowserViewController];
            [self.view addSubview:branchesBrowserViewController.view];
            branchesBrowserViewController.tableView.tableHeaderView = self.headerView;
            break;
        case 2:
            [branchesBrowserViewController removeFromParentViewController];
            [branchesBrowserViewController.view removeFromSuperview];
            [eventTableViewController removeFromParentViewController];
            [eventTableViewController.view removeFromSuperview];
            [self addChildViewController:repositoryViewController];
            [self.view addSubview:repositoryViewController.view];
            repositoryViewController.tableView.tableHeaderView = self.headerView;
            break;
    }
}

-(void)showActionSheet {
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
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
            if (status == 204) {
                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:titleClicked message:@"Repository is being watched now" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alertView show];
            } else {
                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:titleClicked message:@"Starting to watch repository failed" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alertView show];
            }
        } ];
    } else if ([StopWatchingRepo isEqualToString:titleClicked]) {
        [[NetworkProxy sharedInstance] loadStringFromURL:url verb:@"DELETE" block:^(int status, NSDictionary* headerFields, id data) {
            if (status == 204) {
                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:titleClicked message:@"Repository is no longer watched now" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alertView show];
            } else {
                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:titleClicked message:@"Stopping to watch repository failed" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alertView show];
            }
        } ];
    }
    
}
@end
