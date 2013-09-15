//
//  PullToRefreshTableViewControllerViewController.m
//  Github To Go
//
//  Created by Robert Panzer on 18.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PullToRefreshTableViewController.h"
#import <CoreText/CoreText.h>


@interface PullToRefreshTableViewController ()

@end

@implementation PullToRefreshTableViewController

@synthesize reloadPossible;
@synthesize isReloading;

@class UIRefreshControl;

-(void) viewDidLoad {
    [super viewDidLoad];

    UIRefreshControl* refreshControl = [[UIRefreshControl alloc] init];
    NSDictionary *dict = @{(NSString*)kCTForegroundColorAttributeName: [UIColor blackColor]};
    
    
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@"Pull to refresh"
                                                                              attributes:dict];
    
    [refreshControl setAttributedTitle:title];
    [refreshControl addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
}

-(void)reload:(id)sender {
    [self reload];
}

-(void)reload {}

-(void)willReload {
    self.isReloading = YES;
}

-(void)reloadDidFinish {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshControl endRefreshing];
    });
}

@end
