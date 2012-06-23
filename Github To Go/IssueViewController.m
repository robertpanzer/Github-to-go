//
//  IssueViewController.m
//  Hub To Go
//
//  Created by Robert Panzer on 14.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IssueViewController.h"
#import "UITableViewCell+Person.h"
#import "NetworkProxy.h"
#import "PersonViewController.h"

static NSArray *keyPaths;
static NSDictionary* titles;

static NSString* kNumber    = @"number";
static NSString* kCreatedAt = @"createdAt";
static NSString* kUpdatedAt = @"updatedAt";
static NSString* kClosedAt  = @"closedAt";
static NSString* kTitle     = @"title";
static NSString* kBody      = @"body";
static NSString* kState     = @"state";
static NSString* kCreator   = @"creator";

static NSString* titleNumber;
static NSString* titleTitle;
static NSString* titleBody;
static NSString* titleState;
static NSString* titleCreator;
static NSString* titleCreateAt;
static NSString* titleUpdatedAt;
static NSString* titleClosedAt;


@interface IssueViewController ()

@property(nonatomic) BOOL letUserSelectCells;

@end

@implementation IssueViewController

@synthesize issue;
@synthesize letUserSelectCells;

+(void)initialize {
    
    titleNumber    = NSLocalizedString(@"Number", @"Pull Request Number");
    titleTitle     = NSLocalizedString(@"Title", "Pull Request Title");
    titleBody      = NSLocalizedString(@"Body", @"Pull Request Body");
    titleState     = NSLocalizedString(@"State", @"Pull Request State");
    titleCreator   = NSLocalizedString(@"Creator", @"Pull Request Creator");
    titleCreateAt  = NSLocalizedString(@"Created at", @"Pull Request Created At");
    titleUpdatedAt = NSLocalizedString(@"Updated at", @"Pull Request Updated At");
    titleClosedAt  = NSLocalizedString(@"Closed at", @"Pull Request Closed At");
    
    
    keyPaths = [NSArray arrayWithObjects:kNumber, kTitle, kBody, kCreatedAt, kUpdatedAt, kClosedAt, kState, kCreator, nil];
    titles = [NSDictionary dictionaryWithObjectsAndKeys:titleNumber, kNumber,
              titleTitle,kTitle,
              titleBody, kBody,
              titleState, kState,
              titleCreator, kCreator,
              titleCreateAt, kCreatedAt,
              titleUpdatedAt, kUpdatedAt,
              titleClosedAt, kClosedAt,
              nil ];
}


- (id)initWithIssue:(Issue *)anIssue
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.issue = anIssue;
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"%d Elements", keyPaths.count);
    return keyPaths.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static NSString *MultilineCellIdentifier = @"MultilineCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (indexPath.section == 0) {
        NSString* keyPath = [keyPaths objectAtIndex:indexPath.row];
        id value = [issue valueForKeyPath:keyPath];
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
            if ([value isKindOfClass:[NSDate class]]) {
                cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:value dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle];
            } else {
                cell.detailTextLabel.text = [value description];
            }
            return cell;
        }
    } else {
        return nil;
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [keyPaths objectAtIndex:indexPath.row];
    if ([key isEqualToString:kCreator]) {
        if (self.letUserSelectCells) {
            self.letUserSelectCells = YES;
            [[NetworkProxy sharedInstance] loadStringFromURL:self.issue.creator.url block:^(int statusCode, NSDictionary *aHeaderFields, id data) {
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
            NSString* value = [issue valueForKeyPath:keyPath];
            CGSize size = [value sizeWithFont:font constrainedToSize:CGSizeMake(tableView.frame.size.width - 80.0f/*280.0f*/, 1000.0f) lineBreakMode:UILineBreakModeWordWrap];
            
            CGFloat height = size.height + 10;
            
            return height > tableView.rowHeight ? height : tableView.rowHeight;
        } else {
            return self.tableView.rowHeight;
        }
    }
    return -1.0f;
}

@end
