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
    descriptions = [NSArray arrayWithObjects:@"Name", @"Description", @"Owner", @"Id", @"Private", @"Watchers", @"Fork", @"Forks", @"Created at", @"Language", @"Open issues", nil];
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
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:InfoCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:InfoCellIdentifier];
            cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0f];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.textLabel.text = [descriptions objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [self stringValueForIndexPath:indexPath];
        
        return cell;    
    }
}


#pragma mark - Table view delegate

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
    
//    if (indexPath.section == 1 && indexPath.row == 0) {
//        BranchesBrowserViewController* branchesBrowserViewController = [[BranchesBrowserViewController alloc] initWithRepository:repository];
//        [self.navigationController pushViewController:branchesBrowserViewController animated:YES]; 
//    }
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
