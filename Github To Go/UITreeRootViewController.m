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
#import "RPShareUrlController.h"
#import <Twitter/Twitter.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface UITreeRootViewController() 

@property(nonatomic,strong) RPShareUrlController *shareUrlController;

@end

@implementation UITreeRootViewController

@synthesize treeUrl, absolutePath, commit, repository, branchName;
@synthesize treeViewController, branchViewController;
@synthesize htmlUrl, shareUrlController;

-(id)initWithUrl:(NSString*)aTreeUrl absolutePath:(NSString*)anAbsolutePath commit:(Commit *)aCommit repository:(Repository *)aRepository branchName:(NSString*)aBranchName
{
    self = [super init];
    if (self) {
        treeUrl = aTreeUrl;
        absolutePath = anAbsolutePath;
        commit = aCommit;
        repository = aRepository;
        branchName = aBranchName;
        
        htmlUrl = [NSString stringWithFormat:@"%@/tree/%@", aRepository.htmlUrl, aBranchName];
        if (anAbsolutePath.length > 0) {
            self.htmlUrl = [NSString stringWithFormat:@"%@/%@", self.htmlUrl, anAbsolutePath];
        }
        
        
        
        NSString *shareTitle = [NSString stringWithFormat:@"%@/%@/%@", repository.fullName, branchName, absolutePath];
        self.shareUrlController = [[RPShareUrlController alloc] initWithUrl:htmlUrl 
                                                                      title:shareTitle
                                                             viewController:self];

        
        treeViewController = [[TreeViewController alloc] initWithTree:nil
                                                         absolutePath:self.absolutePath
                                                               commit:commit 
                                                           repository:self.repository
                                                           branchName:self.branchName];
        
        branchViewController = [[BranchViewController alloc] initWithGitObject:nil
                                                                  absolutePath:self.absolutePath
                                                                     commitSha:self.commit.sha
                                                                    repository:repository];
        
        [self addChildViewController:treeViewController title:@"Tree"];
        [self addChildViewController:branchViewController title:@"History"];

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
                [self.treeViewController setTree:tree];
            });
        }
    }];
    
    self.navigationItem.rightBarButtonItem = self.shareUrlController.barButtonItem;
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

@end
