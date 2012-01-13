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

@implementation RepositoryViewController

@synthesize repository;

-(id)initWithRepository:(Repository*)repo {
    self = [super initWithNibName:@"RepositoryViewController" bundle:nil];
    if (self) {
        self.navigationItem.title = repo.fullName;
//        [[NetworkProxy sharedInstance] loadStringFromURL:anUrl block:^(int statusCode, id data) {
//            if (statusCode == 200) {
//                NSLog(@"Loaded repository %@", data);
//                self.repository = [[[Repository alloc] initFromJSONObject:data] autorelease];
//                [(UITableView*)self.view reloadData];
//            }
//        }];
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 8;
    } else if (section == 1) {
        return 1;
    } else {
        return -1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* InfoCellIdentifier = @"InfoCell";
    static NSString* DetailCellIdentifier = @"DetailCell";

    if (indexPath.section == 0) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:InfoCellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:InfoCellIdentifier] autorelease];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Name";
                cell.detailTextLabel.text = repository.name;
                break;
            case 1:
                cell.textLabel.text = @"Description";
                cell.detailTextLabel.text = repository.description;
                break;
            case 2:
                cell.textLabel.text = @"Owner";
                cell.detailTextLabel.text = repository.owner.login;
                cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
                break;
            case 3:
                cell.textLabel.text = @"ID";
                cell.detailTextLabel.text = repository.repoId.description;
                break;
            case 4:
                cell.textLabel.text = @"Private";
                cell.detailTextLabel.text = repository.private ? @"Yes" : @"No";
                break;
            case 5:
                cell.textLabel.text = @"Watchers";
                cell.detailTextLabel.text = repository.watchers.description;
                break;
            case 6:
                cell.textLabel.text = @"Fork";
                cell.detailTextLabel.text = repository.fork ? @"Yes" : @"No";
                break;
            case 7:
                cell.textLabel.text = @"Forks";
                cell.detailTextLabel.text = repository.forks.description;
                break;
                
            default:
                break;
        }
        return cell;
    } else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DetailCellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DetailCellIdentifier] autorelease];
            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        }

        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Branches";
                break;
                
            default:
                break;
        }
        return cell;
    } else {
        return nil;
    }
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        BranchesBrowserViewController* branchesBrowserViewController = [[[BranchesBrowserViewController alloc] initWithRepository:repository] autorelease];
        [self.navigationController pushViewController:branchesBrowserViewController animated:YES]; 
    }
}

@end
