//
//  PullRequestCommentViewController.m
//  Github To Go
//
//  Created by Robert Panzer on 15.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PullRequestCommentViewController.h"
#import "NetworkProxy.h"
#import "UITableViewCell+PullRequest.h"

@interface PullRequestCommentViewController ()

@end

@implementation PullRequestCommentViewController

@synthesize pullRequest;
@synthesize comments;
@synthesize addCommentCell;

- (id)initWithPullRequest:(PullRequest *)aPullRequest
{
    self = [super initWithNibName:@"PullRequestCommentViewController" bundle:nil];
    if (self) {
        self.pullRequest = aPullRequest;
    }
    return self;
}

- (IBAction)showAddCommentDialog:(id)sender {
    PullRequestAddCommentViewController *addCommentViewController = [[PullRequestAddCommentViewController alloc] initWithPullRequest:self.pullRequest];
    [self presentModalViewController:addCommentViewController animated:YES];
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [self setAddCommentCell:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadComments];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else {
        return comments.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return addCommentCell;
    } else {
        PullRequestIssueComment *issueComment = [comments objectAtIndex:comments.count - indexPath.row - 1];
        UITableViewCell *cell = [UITableViewCell createPullRequestIssueCommentCellForTableView:self.tableView];
        [cell bindPullRequestIssueComment:issueComment tableView:self.tableView];
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return self.tableView.rowHeight;
    } else if (indexPath.section == 1) {
        PullRequestIssueComment* issueComment = [comments objectAtIndex:comments.count - indexPath.row - 1];
        return [UITableViewCell tableView:self.tableView heightForRowForIssueComment:issueComment];
    }
    return -1.0f;
}


-(void)loadComments {

    [[NetworkProxy sharedInstance] loadStringFromURL:self.pullRequest.issueCommentsUrl 
                                               block:^(int statusCode, NSDictionary *aHeaderFields, id data){
                                                   if (statusCode == 200) {
                                                       NSArray *jsonObjects = (NSArray*)data;
                                                       NSMutableArray *newComments = [NSMutableArray array];
                                                       for (NSDictionary *jsonObject in jsonObjects) {
                                                           PullRequestIssueComment *comment = [[PullRequestIssueComment alloc] initWithJSONObject:jsonObject];
                                                           [newComments addObject:comment];
                                                       }
                                                       self.comments = newComments;
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                           [self.tableView reloadData];
                                                       });
                                                   }
                                               } ];
    
}


@end

@implementation PullRequestAddCommentViewController

@synthesize textView;
@synthesize waitScreen;
@synthesize pullRequest;
@synthesize navigationItem;

- (id)initWithPullRequest:(PullRequest*)aPullRequest
{
    self = [super initWithNibName:@"PullRequestAddCommentViewController" bundle:nil];
    if (self) {
        self.pullRequest = aPullRequest;
    }
    return self;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        self.textView.frame = CGRectMake(self.textView.frame.origin.x, self.textView.frame.origin.y, 320.0f, 200.0f);
    } else {
        self.textView.frame = CGRectMake(self.textView.frame.origin.x, self.textView.frame.origin.y, 480.0f, 94.0f);
    }
    
}
-(void)viewDidLoad {
    [super viewDidLoad];
    UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        self.textView.frame = CGRectMake(self.textView.frame.origin.x, self.textView.frame.origin.y, self.view.frame.size.width, 200.0f);
    } else {
        self.textView.frame = CGRectMake(self.textView.frame.origin.x, self.textView.frame.origin.y, self.view.frame.size.width, 94.0f);
    }
    [self.textView becomeFirstResponder];
}

-(void)viewDidUnload {
    [self setWaitScreen:nil];
    [super viewDidUnload];
    self.textView = nil;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.navigationItem.title = [self.pullRequest.number stringValue];
}

-(void)sendComment:(id)sender {
    self.waitScreen.hidden = NO;
    self.textView.editable = NO;
    NSDictionary *comment = [NSDictionary dictionaryWithObject:self.textView.text forKey:@"body"];
    [[NetworkProxy sharedInstance] sendData:comment ToUrl:self.pullRequest.issueCommentsUrl verb:@"POST" block:^(int statusCode, NSDictionary *aHeaderFields, id data) {
        if (statusCode == 201) {
            NSLog(@"Successfull");
            [(PullRequestCommentViewController*)self.parentViewController loadComments];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissModalViewControllerAnimated:YES];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Adding comment failed" message:[data valueForKey:@"message"] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alertView show];
                self.waitScreen.hidden = true;
            });
        }
    } errorBlock:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Adding comment failed" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alertView show];
                self.waitScreen.hidden = true;
            });
        });
    } ];
}

-(void)cancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

@end
