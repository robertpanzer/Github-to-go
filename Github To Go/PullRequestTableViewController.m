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
#import "PersonViewController.h"

static NSArray *keyPaths;
static NSDictionary* titles;

static NSString* kNumber    = @"number";
static NSString* kCreatedAt = @"createdAt";
static NSString* kUpdatedAt = @"updatedAt";
static NSString* kTitle     = @"title";
static NSString* kBody      = @"body";
static NSString* kState     = @"state";
static NSString* kCreator   = @"creator";
static NSString* kMerged    = @"merged";

static NSString* titleNumber;
static NSString* titleTitle;
static NSString* titleBody;
static NSString* titleState;
static NSString* titleCreator;
static NSString* titleMerged;
static NSString* titleCreateAt;
static NSString* titleUpdatedAt;

static NSSet *isBool;

@interface PullRequestTableViewController ()

@end

@implementation PullRequestTableViewController

@synthesize pullRequest;
@synthesize issueComments;
@synthesize reviewComments;
@synthesize letUserSelectCells;

+(void)initialize {
    
    titleNumber    = NSLocalizedString(@"Number", @"Pull Request Number");
    titleTitle     = NSLocalizedString(@"Title", "Pull Request Title");
    titleBody      = NSLocalizedString(@"Body", @"Pull Request Body");
    titleState     = NSLocalizedString(@"State", @"Pull Request State");
    titleCreator   = NSLocalizedString(@"Creator", @"Pull Request Creator");
    titleMerged    = NSLocalizedString(@"Merged", @"Pull Request Merged");
    titleCreateAt  = NSLocalizedString(@"Created at", @"Pull Request Created At");
    titleUpdatedAt = NSLocalizedString(@"Updated at", @"Pull Request Updated At");

    
    keyPaths = @[kNumber, kTitle, kBody, kCreatedAt, kUpdatedAt, kState, kCreator, kMerged];
    titles = @{kNumber: titleNumber,
               kTitle: titleTitle,
               kBody: titleBody,
               kState: titleState,
               kCreator: titleCreator,
               kMerged: titleMerged,
               kCreatedAt: titleCreateAt,
               kUpdatedAt: titleUpdatedAt};
    
    isBool = [NSSet setWithObjects:kMerged, nil];
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
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        UIImage *backgroundImage = [UIImage imageNamed:@"background"];
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
        self.tableView.backgroundView = backgroundImageView;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.letUserSelectCells = YES;
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
                cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
                cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
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
            if ([isBool containsObject:keyPath]) {
                cell.detailTextLabel.text = [(NSNumber*)value boolValue] ? NSLocalizedString(@"Yes", @"Yes") : NSLocalizedString(@"No", @"No");
                
            } else if ([value isKindOfClass:[NSDate class]]) {
                cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:value dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle];
            } else {
                cell.detailTextLabel.text = [value description];
            }
            return cell;
        }
    } else {
        return nil;
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [keyPaths objectAtIndex:indexPath.row];
    if ([key isEqualToString:kCreator]) {
        if (self.letUserSelectCells) {
            self.letUserSelectCells = YES;
            [[NetworkProxy sharedInstance] loadStringFromURL:self.pullRequest.creator.url block:^(int statusCode, NSDictionary *aHeaderFields, id data) {
                if (statusCode == 200) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        Person *person = [[Person alloc] initWithJSONObject:data];
                        PersonViewController *pwc = [[PersonViewController alloc] initWithPerson:person];
                        [self.navigationController pushViewController:pwc animated:YES];
                    });
                }
            }];
        }
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UIFont* font = [UIFont systemFontOfSize:13.0f];
        NSString* keyPath = [keyPaths objectAtIndex:indexPath.row];
        if ([keyPath isEqualToString:kTitle] || [keyPath isEqualToString:kBody]) {
            NSString* value = [pullRequest valueForKeyPath:keyPath];
            CGSize size = [value sizeWithFont:font
                            constrainedToSize:CGSizeMake(tableView.frame.size.width - 80.0f/*280.0f*/, 1000.0f)
                                lineBreakMode:NSLineBreakByWordWrapping];
            
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
