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
@synthesize eventTableViewController;
@synthesize watched;
@synthesize viewPicker;
@synthesize pullRequestTableViewController;
@synthesize viewSelectorButton;

+(void) initialize {
    WatchRepo = NSLocalizedString(@"Watch Repository", @"Action Sheet Watch Repo");
    StopWatchingRepo = NSLocalizedString(@"Stop watching", @"Action Sheet Stop Watching");
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
    pullRequestTableViewController = [[PullRequestListTableViewController alloc] initWithRepository:repository];
    
    repositoryViewController.view.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    branchesBrowserViewController.view.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    eventTableViewController.view.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    pullRequestTableViewController.view.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);

    [self.view addSubview:eventTableViewController.view];
    [self addChildViewController:eventTableViewController];
    
    
    self.viewPicker.hidden = YES;
    self.viewPicker.dataSource = self;
    self.viewPicker.delegate = self;
    
    self.viewSelectorButton = [[UIBarButtonItem alloc] initWithTitle:@"Events" style:UIBarButtonItemStylePlain target:self action:@selector(showSwitchPicker)];
    if ([[RepositoryStorage sharedStorage].ownRepositories objectForKey:self.repository.fullName] == nil) {
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:
                                                   self.viewSelectorButton,
                                                   [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActionSheet)],
                                                   nil];
    } else {
        self.navigationItem.rightBarButtonItem = self.viewSelectorButton;
    }
}

- (void)viewDidUnload
{
    [self setViewPicker:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.eventTableViewController = nil;
    self.branchesBrowserViewController = nil;
    self.repositoryViewController = nil;
    self.pullRequestTableViewController = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}



-(void)selectedSegmentChanged:(id)sender {
    UISegmentedControl* segmentedControl = sender;
    [self switchView:segmentedControl.selectedSegmentIndex];
}

-(void)switchView:(NSUInteger)index {
    switch (index) {
        case 0:
            [repositoryViewController removeFromParentViewController];
            [repositoryViewController.view removeFromSuperview];
            [branchesBrowserViewController removeFromParentViewController];
            [branchesBrowserViewController.view removeFromSuperview];
            [pullRequestTableViewController removeFromParentViewController];
            [pullRequestTableViewController.view removeFromSuperview];
            [self addChildViewController:eventTableViewController];
            [self.view addSubview:eventTableViewController.view];
            break;
        case 1:
            [repositoryViewController removeFromParentViewController];
            [repositoryViewController.view removeFromSuperview];
            [eventTableViewController removeFromParentViewController];
            [eventTableViewController.view removeFromSuperview];
            [pullRequestTableViewController removeFromParentViewController];
            [pullRequestTableViewController.view removeFromSuperview];
            [self addChildViewController:branchesBrowserViewController];
            [self.view addSubview:branchesBrowserViewController.view];
            break;
        case 2:
            [branchesBrowserViewController removeFromParentViewController];
            [branchesBrowserViewController.view removeFromSuperview];
            [eventTableViewController removeFromParentViewController];
            [eventTableViewController.view removeFromSuperview];
            [pullRequestTableViewController removeFromParentViewController];
            [pullRequestTableViewController.view removeFromSuperview];
            [self addChildViewController:repositoryViewController];
            [self.view addSubview:repositoryViewController.view];
            break;
        case 3:
            [branchesBrowserViewController removeFromParentViewController];
            [branchesBrowserViewController.view removeFromSuperview];
            [eventTableViewController removeFromParentViewController];
            [eventTableViewController.view removeFromSuperview];
            [repositoryViewController removeFromParentViewController];
            [repositoryViewController.view removeFromSuperview];
            [self addChildViewController:pullRequestTableViewController];
            [self.view addSubview:pullRequestTableViewController.view];
            break;
    }
    repositoryViewController.view.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    branchesBrowserViewController.view.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    eventTableViewController.view.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    pullRequestTableViewController.view.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);

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


-(void)showSwitchPicker {
    self.viewPicker.hidden = NO;
    [self.view bringSubviewToFront:viewPicker];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 4;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (row) {
        case 0:
            return NSLocalizedString(@"Events", @"RepositoryViewPicker");
        case 1:
            return NSLocalizedString(@"Branches", @"RepositoryViewPicker");
        case 2:
            return NSLocalizedString(@"Info", @"RepositoryViewPicker");
        case 3:
            return NSLocalizedString(@"Pulls", @"RepositoryViewPicker");
//        case 4:
//            return NSLocalizedString(@"Issues", @"RepositoryViewPicker");
        default:
            return nil;
    }
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.viewPicker.hidden = YES;
    self.viewSelectorButton.title = [pickerView.delegate pickerView:pickerView titleForRow:row forComponent:component];
    [self switchView:row];
}

@end
