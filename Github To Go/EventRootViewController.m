//
//  EventRootViewController.m
//  Hub To Go
//
//  Created by Robert Panzer on 22.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventRootViewController.h"
#import "EventTableViewController.h"
#import "Settings.h"

@interface EventRootViewController ()

@property BOOL isUserAuthorized;

@end

@implementation EventRootViewController

@synthesize isUserAuthorized;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.tabBarItem = [[UITabBarItem alloc]initWithTabBarSystemItem:UITabBarSystemItemFeatured tag:0];
    }
    return self;
}


-(void)viewWillAppear:(BOOL)animated {
    
    if ([Settings sharedInstance].isUsernameSet) { 
        if (self.childViewControllers.count != 2) {
            [self removeAllChildControllers];
            NSString *username = [Settings sharedInstance].username;
            UIViewController* eventViewController1 = [[EventTableViewController alloc] initWithUrl:[NSString stringWithFormat:@"https://api.github.com/users/%@/received_events", username]];
            [self addChildViewController:eventViewController1 title:@"Watched"];
            
            UIViewController* eventViewController2 = [[EventTableViewController alloc] initWithUrl:[NSString stringWithFormat:@"https://api.github.com/users/%@/events", username]];
            [self addChildViewController:eventViewController2 title:@"Performed"];
        }
    } else if (self.childViewControllers.count != 1) {
        [self removeAllChildControllers];
        UIViewController* eventViewController1 = [[EventTableViewController alloc] initWithUrl:[NSString stringWithFormat:@"https://api.github.com/events"]];
        [self addChildViewController:eventViewController1 title:@"All"];
    }
    
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
     
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
