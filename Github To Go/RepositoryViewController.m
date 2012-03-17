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

static NSArray *keys, *descriptions;
static BOOL *isBool;

@implementation RepositoryViewController

@synthesize repository;

+(void)initialize {
    keys = [NSArray arrayWithObjects:@"name", @"description", @"owner", @"repoId", @"private", @"watchers", @"fork", @"forks", @"createdAt", @"language", @"openIssues", nil];
    descriptions = [NSArray arrayWithObjects:@"Name", @"Description", @"Owner", @"Id", @"Private", @"Watchers", @"Fork", @"Forks", @"Created at", @"Language", @"Open issues", nil];
    isBool = calloc(keys.count, sizeof(BOOL));
    isBool[0] = NO;
    isBool[1] = NO;
    isBool[2] = NO;
    isBool[3] = NO;
    isBool[4] = YES;
    isBool[5] = NO;
    isBool[6] = YES;
    isBool[7] = NO;
    isBool[8] = NO;
    isBool[9] = NO;
    isBool[10] = NO;
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
        
        if ([value isKindOfClass:[NSString class]]) {
            cell.detailTextLabel.text = value;
        } else if ([value isKindOfClass:[NSNumber class]]) {
            if (isBool[indexPath.row]) {
                cell.detailTextLabel.text = [value boolValue] ? NSLocalizedString(@"Yes",nil) : NSLocalizedString(@"No", nil);
            } else {
                cell.detailTextLabel.text = [value stringValue];
            }
        }

        return cell;    
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        BranchesBrowserViewController* branchesBrowserViewController = [[BranchesBrowserViewController alloc] initWithRepository:repository];
        [self.navigationController pushViewController:branchesBrowserViewController animated:YES]; 
    }
}



@end
