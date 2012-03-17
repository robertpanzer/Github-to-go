//
//  PullRequestTableViewController.m
//  Github To Go
//
//  Created by Robert Panzer on 10.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PullRequestTableViewController.h"
#import "UITableViewCell+Person.h"
#import "CommitFile.h"
#import "NetworkProxy.h"
#import "UITableViewCell+CommitFile.h"
#import "UITableViewCell+PullRequest.h"


static NSArray *keyPaths;
static NSDictionary* titles;

static NSString* kNumber  = @"number";
static NSString* kTitle   = @"title";
static NSString* kBody    = @"body";
static NSString* kState   = @"state";
static NSString* kCreator = @"creator";
static NSString* kMerged  = @"merged";

static NSString* titleNumber  = @"Number";
static NSString* titleTitle   = @"Title";
static NSString* titleBody    = @"Body";
static NSString* titleState   = @"State";
static NSString* titleCreator = @"Creator";
static NSString* titleMerged  = @"Merged";

@interface PullRequestTableViewController ()

@end

@implementation PullRequestTableViewController

@synthesize pullRequest;
@synthesize issueComments;
@synthesize reviewComments;

+(void)initialize {
    keyPaths = [NSArray arrayWithObjects:kNumber, kTitle, kBody, kState, kCreator, kMerged, nil];
    titles = [NSDictionary dictionaryWithObjectsAndKeys:titleNumber, kNumber,
                                                        titleTitle,kTitle,
                                                        titleBody, kBody,
                                                        titleState, kState,
                                                        titleCreator, kCreator,
                                                        titleMerged, kMerged,
                                                        nil ];
}

- (id)initWithPullRequest:(PullRequest*)aPullRequest
{
    self = [super initWithStyle:UITableViewStyleGrouped];//NibName:@"PullRequestTableViewController" bundle:nil];
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (reviewComments == nil) {
        [[NetworkProxy sharedInstance] loadStringFromURL:pullRequest.reviewCommentsUrl block:^(int statusCode, NSDictionary* headerFields, id data) {
            if (statusCode == 200) {
                NSArray* commentsArray = (NSArray*)data;
                NSMutableArray* newComments = [NSMutableArray array];
                for (NSDictionary* jsonObject in commentsArray) {
                    PullRequestReviewComment* reviewComment = [[PullRequestReviewComment alloc] initWithJSONObject:jsonObject];
                }
                self.reviewComments = newComments;
                dispatch_async(dispatch_get_main_queue(), ^() {
                    [self.tableView reloadData];
                });
            }
        }];
    }

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
    return keyPaths.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static NSString *MultilineCellIdentifier = @"Multiline";

    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        NSString* keyPath = [keyPaths objectAtIndex:indexPath.row];
        id value = [pullRequest valueForKeyPath:keyPath];
        if ([value isKindOfClass:[Person class]]) {
            cell = [UITableViewCell createPersonCellForTableView:self.tableView];
            [cell bindPerson:value role:[titles objectForKey:keyPath] tableView:self.tableView];
            return cell;
        } else if ([keyPath isEqualToString:kTitle] || [keyPath isEqualToString:kBody]) {
            cell = [tableView dequeueReusableCellWithIdentifier:MultilineCellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MultilineCellIdentifier];
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 
                                              reuseIdentifier:CellIdentifier];
                cell.textLabel.font = [UIFont systemFontOfSize:13.0f];
                cell.detailTextLabel.font = [UIFont systemFontOfSize:13.0f];
                cell.detailTextLabel.numberOfLines = 0;
                cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
                cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
            }
            cell.textLabel.text = [titles valueForKey:keyPath];
            cell.detailTextLabel.text = [value description];
            return cell;
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 
                                              reuseIdentifier:CellIdentifier];
                cell.textLabel.font = [UIFont systemFontOfSize:13.0f];
                cell.detailTextLabel.font = [UIFont systemFontOfSize:13.0f];
            }
            cell.textLabel.text = [titles valueForKey:keyPath];
            cell.detailTextLabel.text = [value description];
            return cell;
        }
    } else {
        return nil;
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"%f %f %f %f", cell.textLabel.frame.origin.x,
          cell.textLabel.frame.origin.y,
          cell.textLabel.frame.size.width,
          cell.textLabel.frame.size.height);
    NSLog(@"%@ %f", cell.textLabel.font.fontName, cell.textLabel.font.pointSize);
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UIFont* font = [UIFont systemFontOfSize:13.0f];
        NSString* keyPath = [keyPaths objectAtIndex:indexPath.row];
        if ([keyPath isEqualToString:kTitle] || [keyPath isEqualToString:kBody]) {
            NSString* value = [pullRequest valueForKeyPath:keyPath];
            CGSize size = [value sizeWithFont:font constrainedToSize:CGSizeMake(tableView.frame.size.width - 80.0f/*280.0f*/, 1000.0f) lineBreakMode:UILineBreakModeWordWrap];
            
            CGFloat height = size.height + 10;
            
            return height > tableView.rowHeight ? height : tableView.rowHeight;
        } else {
            return self.tableView.rowHeight;
        }
    } else if (indexPath.section == 1) {
        PullRequestIssueComment* issueComment = [issueComments objectAtIndex:indexPath.row];
        return [UITableViewCell tableView:self.tableView heightForRowForIssueComment:issueComment];
    }
    return -1.0f;
}

@end
