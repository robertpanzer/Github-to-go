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
#import <Twitter/Twitter.h>
#import <MessageUI/MFMailComposeViewController.h>


static NSString* WatchRepo;
static NSString* StopWatchingRepo;

@interface UIRepositoryRootViewController() <MFMailComposeViewControllerDelegate>

@property(strong,nonatomic) NSMutableArray* actionSheetTitles;

@end

@implementation UIRepositoryRootViewController

@synthesize repository;
@synthesize watched;
@synthesize actionSheetTitles;

+(void) initialize {
    WatchRepo = NSLocalizedString(@"Watch Repository", @"Action Sheet Watch Repo");
    StopWatchingRepo = NSLocalizedString(@"Stop watching", @"Action Sheet Stop Watching");
}

- (id)initWithRepository:(Repository*)aRepository
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.repository = aRepository;
        self.watched = [[RepositoryStorage sharedStorage] repositoryIsWatched:aRepository];
        
        [self addChildViewController:[[EventTableViewController alloc] initWithRepository:repository] 
                               title:@"Events"];
        [self addChildViewController:[[BranchesBrowserViewController alloc] initWithRepository:repository] 
                               title:@"Branches"];
        [self addChildViewController:[[RepositoryViewController alloc] initWithRepository:repository] 
                               title:@"Info"];
        [self addChildViewController:[[PullRequestListTableViewController alloc] initWithRepository:repository] 
                               title:@"Pulls"];
        [self addChildViewController:[[IssueListViewController alloc] initWithRepository:repository] 
                               title:@"Issues"];
        
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = repository.fullName;
    self.navigationController.navigationBarHidden = NO;
    
    self.actionSheetTitles = [NSMutableArray array];
    if (![[RepositoryStorage sharedStorage] repositoryIsOwned:self.repository]) {
        if (![[RepositoryStorage sharedStorage] repositoryIsWatched:repository]){
            [self.actionSheetTitles addObject:WatchRepo];
        } else {
            [self.actionSheetTitles addObject:StopWatchingRepo];
        }
    }
    
    if ([TWTweetComposeViewController canSendTweet]) {
        [self.actionSheetTitles addObject:@"Tweet"];
    }
    
    if ([MFMailComposeViewController canSendMail]) {
        [self.actionSheetTitles addObject:@"Mail"];
    }
    
    if (self.actionSheetTitles.count > 0) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction 
                                                                                               target:self 
                                                                                               action:@selector(showActionSheet)];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


-(void)showActionSheet {
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
                                                             delegate:self 
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel Button") 
                                               destructiveButtonTitle:nil otherButtonTitles:nil];
    if (![[RepositoryStorage sharedStorage] repositoryIsOwned:self.repository]) {
        if (![[RepositoryStorage sharedStorage] repositoryIsWatched:repository]){
            [actionSheet addButtonWithTitle:WatchRepo];
        } else {
            [actionSheet addButtonWithTitle:StopWatchingRepo];
        }
    }
    
    if ([TWTweetComposeViewController canSendTweet]) {
        [actionSheet addButtonWithTitle:@"Tweet"];
    }
    
    if ([MFMailComposeViewController canSendMail]) {
        [actionSheet addButtonWithTitle:@"Mail"];
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
    } else if ([@"Tweet" isEqualToString:titleClicked]) {
        TWTweetComposeViewController *tweetController = [[TWTweetComposeViewController alloc] init];
        [tweetController addURL:[NSURL URLWithString:repository.htmlUrl]];
        [self presentModalViewController:tweetController animated:YES];
    } else if ([@"Mail" isEqualToString:titleClicked]) {
        MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
        [mailController setMessageBody:repository.htmlUrl isHTML:NO];
        mailController.mailComposeDelegate = self;
        [self presentModalViewController:mailController animated:YES];
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissModalViewControllerAnimated:YES];
}

@end

