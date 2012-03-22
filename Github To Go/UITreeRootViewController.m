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

@synthesize treeUrl, absolutePath, commit, repository, branchName;

-(id)initWithUrl:(NSString*)aTreeUrl absolutePath:(NSString*)anAbsolutePath commit:(Commit *)aCommit repository:(Repository *)aRepository branchName:(NSString*)aBranchName
{
    self = [super initWithNibName:@"UITreeRootViewController" bundle:nil];
    if (self) {
        self.treeUrl = aTreeUrl;
        self.absolutePath = anAbsolutePath;
        self.commit = aCommit;
        self.repository = aRepository;
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
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 400.0f, 40.0f)];
    titleLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
    titleLabel.text = self.absolutePath;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    self.navigationItem.titleView = titleLabel;
    [[NetworkProxy sharedInstance] loadStringFromURL:self.treeUrl block:^(int statusCode, NSDictionary* headerFields, id data) {
        if (statusCode == 200) {
            dispatch_async(dispatch_get_main_queue(), ^() {
                Tree* tree = [[Tree alloc] initWithJSONObject:data absolutePath:self.absolutePath commitSha:self.commit.sha];
                
                treeViewController = [[TreeViewController alloc] initWithTree:tree
                                                                 absolutePath:self.absolutePath
                                                                       commit:commit 
                                                                   repository:self.repository
                                                                   branchName:self.branchName];
                
                [self addChildViewController:treeViewController];
                
                [self.view addSubview:treeViewController.view];
                treeViewController.view.frame = CGRectMake(0.0f, 44.0f, self.view.frame.size.width, self.view.frame.size.height -44.0f);
                
                branchViewController = [[BranchViewController alloc] initWithGitObject:tree
                                                                             commitSha:self.commit.sha
                                                                            repository:repository];
                
                branchViewController.view.frame = CGRectMake(0.0f, 44.0f, self.view.frame.size.width, self.view.frame.size.height - 44.0f);
                
            });
        }
    }];

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
    treeViewController.tableView.tableHeaderView = nil;
    branchViewController.tableView.tableHeaderView = nil;
    switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            [self addChildViewController:treeViewController];
            [self.view addSubview:treeViewController.view];
            [branchViewController removeFromParentViewController];
            [branchViewController.view removeFromSuperview];
            break;
        case 1:
            [treeViewController removeFromParentViewController];
            [treeViewController.view removeFromSuperview];
            [self addChildViewController:branchViewController];
            [self.view addSubview:branchViewController.view];
            break;
    }
    treeViewController.view.frame = CGRectMake(0.0f, 44.0f, self.view.frame.size.width, self.view.frame.size.height - 44.0f);
    branchViewController.view.frame = CGRectMake(0.0f, 44.0f, self.view.frame.size.width, self.view.frame.size.height - 44.0f);

}


@end
