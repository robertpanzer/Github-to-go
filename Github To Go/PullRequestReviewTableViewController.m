//
//  PullRequestReviewTableViewController.m
//  Github To Go
//
//  Created by Robert Panzer on 14.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PullRequestReviewTableViewController.h"
#import "PullRequest.h"
#import "NetworkProxy.h"
#import "CommitFile.h"
#import "UITableViewCell+CommitFile.h"
#import "BlobViewController.h"
#import "CommitComment.h"

@interface PullRequestReviewTableViewController ()

@end

@implementation PullRequestReviewTableViewController

@synthesize pullRequest;
@synthesize files;
@synthesize comments;

- (id)initWithPullRequest:(PullRequest*)aPullRequest
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.pullRequest = aPullRequest;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UIImage *backgroundImage = [UIImage imageNamed:@"background"];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    self.tableView.backgroundView = backgroundImageView;

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (files == nil) {
        
        NSString* url = [self.pullRequest.selfUrl stringByAppendingString:@"/files"];
        [[NetworkProxy sharedInstance] loadStringFromURL:url block:^(int statusCode, NSDictionary* headerFields, id data) {
            if (statusCode == 200) {
                NSArray* filesArray = (NSArray*)data;
                NSMutableArray* newFiles = [NSMutableArray array];
                for (NSDictionary* jsonObject in filesArray) {
                    CommitFile* commitFile = [[CommitFile alloc] initWithJSONObject:jsonObject commit:nil];
                    [newFiles addObject:commitFile];
                }
                self.files = newFiles;
                dispatch_async(dispatch_get_main_queue(), ^() {
                    [self.tableView reloadData];
                });
            }
        }];
    }
    [[NetworkProxy sharedInstance] loadStringFromURL:self.pullRequest.reviewCommentsUrl block:^(int statusCode, NSDictionary* headerFields, id data) {
        if (statusCode == 200) {
            NSMutableDictionary *newComments = [NSMutableDictionary dictionary];
            for (NSDictionary *jsonObject in data) {
                CommitComment *comment = [[CommitComment alloc] initWithJSONObject:jsonObject];
                if (comment.position >= 0) {
                    NSMutableArray *commentsForFile = [newComments objectForKey:comment.path];
                    if (commentsForFile == nil) {
                        commentsForFile = [NSMutableArray array];
                        [newComments setObject:commentsForFile forKey:comment.path];
                    }
                    [commentsForFile addObject:comment];
                }
            }
            self.comments = newComments;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
        }
    }];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return files.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommitFile* commitFile = [self.files objectAtIndex:indexPath.row];
    UITableViewCell *cell = [UITableViewCell createCommitFileCellForTableView:self.tableView];
    [cell bindCommitFile:commitFile comments:[self.comments objectForKey:commitFile.fileName] tableView:self.tableView];
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    CommitFile *commitFile = [self.files objectAtIndex:indexPath.row];
    BlobViewController *blobViewController = [[BlobViewController alloc] initWithCommitFile:commitFile comments:[self.comments objectForKey:commitFile.fileName]];
    [self.navigationController pushViewController:blobViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CommitFile* commitFile = [self.files objectAtIndex:indexPath.row];
    return [UITableViewCell tableView:tableView heightForRowForCommitFile:commitFile comments:[self.comments objectForKey:commitFile.fileName]];
}

@end
