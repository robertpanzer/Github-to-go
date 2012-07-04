//
//  RepositoryViewController.m
//  Github To Go
//
//  Created by Robert Panzer on 06.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RepositoryViewController.h"
#import "NetworkProxy.h"
#import "BranchesBrowserViewController.h"
#import "UITableViewCell+Person.h"
#import "PersonViewController.h"


static NSString *kName = @"name";
static NSString *kDescription = @"description";
static NSString *kOwner = @"owner";
static NSString *kRepoId = @"repoId";
static NSString *kPrivate = @"private";
static NSString *kWatchers = @"watchers";
static NSString *kFork = @"fork";
static NSString *kForks = @"forks";
static NSString *kCreatedAt = @"createdAt";
static NSString *kLanguage = @"language";
static NSString *kOpenIssues = @"openIssues";


static NSArray *keys, *descriptions;
static NSSet *isBool;


@interface RepositoryViewController()

-(NSString*)stringValueForIndexPath:(NSIndexPath*)indexPath;

@end

@implementation RepositoryViewController

@synthesize repository;

+(void)initialize {
    keys = [NSArray arrayWithObjects:
            kName, 
            kDescription, 
            kOwner, 
            kRepoId, 
            kPrivate, 
            kWatchers, 
            kFork, 
            kForks, 
            kCreatedAt, 
            kLanguage, 
            kOpenIssues, 
            nil];
    descriptions = [NSArray arrayWithObjects:
                    NSLocalizedString(@"Name", @"Repo name"), 
                    NSLocalizedString(@"Description", @"Repo description"), 
                    NSLocalizedString(@"Owner", @"Repo owner"), 
                    NSLocalizedString(@"Id", @"Repo id"), 
                    NSLocalizedString(@"Private", @"Repo private"), 
                    NSLocalizedString(@"Watchers", @"Repo watchers"), 
                    NSLocalizedString(@"Fork", @"Repo fork"), 
                    NSLocalizedString(@"Forks", @"Repo forks"), 
                    NSLocalizedString(@"Created at", @"Repo created at"), 
                    NSLocalizedString(@"Language", @"Repo language"), 
                    NSLocalizedString(@"Open issues", @"Repo open issues"), 
                    nil];
    isBool = [NSSet setWithObjects:kPrivate, kFork, nil];
}

-(id)initWithRepository:(Repository*)repo {
    self = [super initWithNibName:@"RepositoryViewController" bundle:nil];
    if (self) {
        self.repository = repo;
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (repository == nil) {
        return 0;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return keys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    id value = [repository valueForKeyPath:[keys objectAtIndex:indexPath.row]];
    if ([value isKindOfClass:[Person class]]) {
        UITableViewCell *cell = [UITableViewCell createPersonCellForTableView:self.tableView];
        [cell bindPerson:value role:[descriptions objectAtIndex:indexPath.row] tableView:self.tableView];
        return cell;
    } else {
        static NSString* InfoCellIdentifier = @"InfoCell";
        static NSString* DescriptionCellIdentifier = @"DescriptionCell";
        if ([kDescription isEqualToString:[keys objectAtIndex:indexPath.row]]) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DescriptionCellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 
                                              reuseIdentifier:DescriptionCellIdentifier];
                cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
                cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0f];
                cell.detailTextLabel.numberOfLines = 0;
                cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
                cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
            }
            cell.textLabel.text = [descriptions objectAtIndex:indexPath.row];
            cell.detailTextLabel.text = [value description];
            return cell;
            
        } else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:InfoCellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:InfoCellIdentifier];
                cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
                cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0f];
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.textLabel.text = [descriptions objectAtIndex:indexPath.row];
            cell.detailTextLabel.text = [self stringValueForIndexPath:indexPath];
            return cell;    
        }        
    }
}


#pragma mark - Table view delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UIFont* font = [UIFont systemFontOfSize:14.0f];
        NSString* keyPath = [keys objectAtIndex:indexPath.row];
        if ([keyPath isEqualToString:kDescription]) {
            NSString* value = [repository valueForKeyPath:keyPath];
            CGSize size = [value sizeWithFont:font constrainedToSize:CGSizeMake(tableView.frame.size.width - 118.0f/*280.0f*/, 1000.0f) lineBreakMode:UILineBreakModeWordWrap];
            
            CGFloat height = size.height + 14.0f;
            
            return height > tableView.rowHeight ? height : tableView.rowHeight;
        } else {
            return self.tableView.rowHeight;
        }
    }
    return -1.0f;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [keys objectAtIndex:indexPath.row];

    if (key == kOwner) {
        [[NetworkProxy sharedInstance] loadStringFromURL:self.repository.owner.url block:^(int statusCode, NSDictionary *aHeaderFields, id data) {
            if (statusCode == 200) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    Person *newPerson = [[Person alloc] initWithJSONObject:data];
                    PersonViewController *pwc = [[PersonViewController alloc] initWithPerson:newPerson];
                    [self.navigationController pushViewController:pwc animated:YES];
                });
            }
        }];
    }
}


-(NSString*)stringValueForIndexPath:(NSIndexPath*)indexPath {
    NSString *key = [keys objectAtIndex:indexPath.row];
    id value = [repository valueForKey:key];
    
    if (value == [NSNull null]) {
        return nil;
    } else if ([value isKindOfClass:[NSDate class]]) {
        return [NSDateFormatter localizedStringFromDate:value dateStyle:NSDateFormatterFullStyle timeStyle:NSDateFormatterNoStyle];
    } else if ([isBool containsObject:key]) {
        NSNumber *boolNumber = (NSNumber*)value;
        return [boolNumber boolValue] ? NSLocalizedString(@"Yes", @"Yes") : NSLocalizedString(@"No", @"No");
    } else if ([value isKindOfClass:[NSNumber class]]) {
        return [value stringValue];
    } else {
        return [value description];
    }
    
}

@end
