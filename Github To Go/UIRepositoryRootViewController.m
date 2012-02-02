//
//  UIRepositoryRootViewController.m
//  Github To Go
//
//  Created by Robert Panzer on 29.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIRepositoryRootViewController.h"
#import "RepositoryViewController.h"

@implementation UIRepositoryRootViewController

@synthesize repository, repositoryViewController, branchesBrowserViewController, headerView;

- (id)initWithRepository:(Repository*)aRepository
{
    self = [super initWithNibName:@"UIRepositoryRootViewController" bundle:nil];
    if (self) {
        // Custom initialization
        self.repository = aRepository;
//        self.tabBarItem.title = @"Repo";

        repositoryViewController = [[RepositoryViewController alloc] initWithRepository:repository];
        branchesBrowserViewController = [[BranchesBrowserViewController alloc] initWithRepository:repository];
        [self addChildViewController:repositoryViewController];
        [self addChildViewController:branchesBrowserViewController];

        
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
    
    [self.view addSubview:repositoryViewController.view];
    repositoryViewController.view.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);

    [self.view addSubview:branchesBrowserViewController.view];
    branchesBrowserViewController.view.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);

    repositoryViewController.tableView.tableHeaderView = self.headerView;
    
    repositoryViewController.view.hidden = NO;
    branchesBrowserViewController.view.hidden = YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


-(void)selectedSegmentChanged:(id)sender {
    UISegmentedControl* segmentedControl = sender;
    repositoryViewController.tableView.tableHeaderView = nil;
    branchesBrowserViewController.tableView.tableHeaderView = nil;
    switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            repositoryViewController.view.hidden = NO;
            branchesBrowserViewController.view.hidden = YES;
            repositoryViewController.tableView.tableHeaderView = self.headerView;
            break;
        case 1:
            repositoryViewController.view.hidden = YES;
            branchesBrowserViewController.view.hidden = NO;
            branchesBrowserViewController.tableView.tableHeaderView = self.headerView;
            break;
    }
}


- (void)dealloc {
    [repository release];
    [repositoryViewController release];
    [branchesBrowserViewController release];
    [headerView release];
    [super dealloc];
}

@end
