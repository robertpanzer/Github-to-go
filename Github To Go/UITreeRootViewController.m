//
//  UITreeRootViewController.m
//  Github To Go
//
//  Created by Robert Panzer on 30.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UITreeRootViewController.h"
#import "TreeViewController.h"
#import "BranchViewController.h"
#import "NetworkProxy.h"

@implementation UITreeRootViewController

@synthesize headerView, treeUrl, absolutePath, commit, repository, branchName;

-(id)initWithUrl:(NSString*)aTreeUrl absolutePath:(NSString*)anAbsolutePath commit:(Commit *)aCommit repository:(Repository *)aRepository branchName:(NSString*)aBranchName
{
    self = [super initWithNibName:@"UITreeRootViewController" bundle:nil];
    if (self) {
        self.treeUrl = aTreeUrl;
        self.absolutePath = anAbsolutePath;
        self.commit = aCommit;
        self.repository = aRepository;
        loadedInitialHistory = NO;
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
    [[NetworkProxy sharedInstance] loadStringFromURL:self.treeUrl block:^(int statusCode, NSDictionary* headerFields, id data) {
        if (statusCode == 200) {
            NSLog(@"Loaded tree %@", data);
            Tree* tree = [[[Tree alloc] initWithJSONObject:data absolutePath:self.absolutePath commitSha:self.commit.sha] autorelease];
            
            treeViewController = [[TreeViewController alloc] initWithTree:tree
                                                             absolutePath:self.absolutePath
                                                                   commit:commit 
                                                               repository:self.repository
                                                               branchName:self.branchName];
            
            [self addChildViewController:treeViewController];
            
            branchViewController = [[BranchViewController alloc] initWithGitObject:tree
                                                                         commitSha:self.commit.sha
                                                                        repository:repository];
            
            [self addChildViewController:branchViewController];

            
            [self.view addSubview:treeViewController.view];
            treeViewController.view.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
            
            [self.view addSubview:branchViewController.view];
            branchViewController.view.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
            
            treeViewController.tableView.tableHeaderView = self.headerView;
            
            treeViewController.view.hidden = NO;
            branchViewController.view.hidden = YES;

        }
    }];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.headerView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(void)selectedSegmentChanged:(id)sender {
    UISegmentedControl* segmentedControl = sender;
    treeViewController.tableView.tableHeaderView = nil;
    branchViewController.tableView.tableHeaderView = nil;
    switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            treeViewController.view.hidden = NO;
            branchViewController.view.hidden = YES;
            treeViewController.tableView.tableHeaderView = self.headerView;
            break;
        case 1:
            treeViewController.view.hidden = YES;
            branchViewController.view.hidden = NO;
            branchViewController.tableView.tableHeaderView = self.headerView;
            if (!loadedInitialHistory) {
                [branchViewController loadCommits];
                loadedInitialHistory = YES;
            }
            break;
    }
}


- (void)dealloc {
    [treeUrl release];
    [absolutePath release];
    [branchName release];
    [commit release];
    [repository release];
    [super dealloc];
}
@end
