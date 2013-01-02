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
#import "RPShareUrlController.h"
#import "RPWatchRepoActivity.h"
#import "RPStarRepositoryActivity.h"

static NSString* WatchRepo;
static NSString* StopWatchingRepo;

@interface UIRepositoryRootViewController()

@property(strong,nonatomic) NSMutableArray* actionSheetTitles;
@property(nonatomic,strong) RPShareUrlController *shareUrlController;

@end

@implementation UIRepositoryRootViewController


+(void) initialize {
    WatchRepo = NSLocalizedString(@"Watch Repository", @"Action Sheet Watch Repo");
    StopWatchingRepo = NSLocalizedString(@"Stop watching", @"Action Sheet Stop Watching");
}

- (id)initWithRepository:(Repository*)aRepository
{
    self = [super init];
    if (self) {
        // Custom initialization
        _repository = aRepository;
        _watched = [[RepositoryStorage sharedStorage] repositoryIsWatched:aRepository];
        
        [self addChildViewController:[[EventTableViewController alloc] initWithRepository:_repository]
                               title:@"Events"];
        [self addChildViewController:[[BranchesBrowserViewController alloc] initWithRepository:_repository]
                               title:@"Branches"];
        [self addChildViewController:[[RepositoryViewController alloc] initWithRepository:_repository]
                               title:@"Info"];
        [self addChildViewController:[[PullRequestListTableViewController alloc] initWithRepository:_repository]
                               title:@"Pulls"];
        [self addChildViewController:[[IssueListViewController alloc] initWithRepository:_repository]
                               title:@"Issues"];
        
        
        if (NSClassFromString(@"UIActivityViewController") != NULL) {
            _shareUrlController = [[RPShareUrlController alloc] initWithUrl:[NSString stringWithFormat:@"http://github.com/%@", _repository.fullName]
                                                                          title:_repository.fullName
                                                                 viewController:self];
            [_shareUrlController addActivity:[[RPWatchRepoActivity alloc] initWithRepository:_repository]];
            [_shareUrlController addActivity:[[RPStarRepositoryActivity alloc] initWithRepository:_repository]];

            self.navigationItem.rightBarButtonItem = self.shareUrlController.barButtonItem;
            
        } else {

            _shareUrlController = [[RPShareUrlController alloc] initWithUrl:[NSString stringWithFormat:@"http://github.com/%@", _repository.fullName]
                                                                      title:_repository.fullName
                                                             viewController:self];
        
            if (![[RepositoryStorage sharedStorage] repositoryIsOwned:self.repository]) {
                if (![[RepositoryStorage sharedStorage] repositoryIsWatched:_repository]) {
                    [_shareUrlController addAction:WatchRepo
                                             block:^() {
                                                 NSString* url = [NSString stringWithFormat:@"https://api.github.com/user/watched/%@", self.repository.fullName];
                                                 [[NetworkProxy sharedInstance] loadStringFromURL:url verb:@"PUT" block:^(int status, NSDictionary* headerFields, id data) {
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         if (status == 204) {
                                                             UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:WatchRepo message:NSLocalizedString(@"Repository is being watched now", @"Alert View") delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                                                             [alertView show];
                                                         } else {
                                                             UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:WatchRepo message:NSLocalizedString(@"Starting to watch repository failed", @"Alert view") delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                                                             [alertView show];
                                                         }
                                                     });
                                                 } ];
                                             }];
                } else {
                    [_shareUrlController addAction:StopWatchingRepo
                                            block:^() {
                                                NSString* url = [NSString stringWithFormat:@"https://api.github.com/user/watched/%@", self.repository.fullName];
                                                [[NetworkProxy sharedInstance] loadStringFromURL:url verb:@"DELETE" block:^(int status, NSDictionary* headerFields, id data) {
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        if (status == 204) {
                                                            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:StopWatchingRepo message:NSLocalizedString(@"Repository is no longer watched now", @"Alert view") delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                                                            [alertView show];
                                                        } else {
                                                            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:StopWatchingRepo message:NSLocalizedString(@"Stopping to watch repository failed", @"Alert view") delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                                                            [alertView show];
                                                        }
                                                    });
                                                }];
                                            }];
                }
            }
        }

    }
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.shareUrlController.barButtonItem;

}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = self.repository.fullName;
    self.navigationController.navigationBarHidden = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end

