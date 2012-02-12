//
//  EventTableViewController.m
//  Github To Go
//
//  Created by Robert Panzer on 09.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventTableViewController.h"
#import "NetworkProxy.h"
#import "GithubEvent.h"

@interface EventTableViewController()

-(void) loadEvents;

@end

@implementation EventTableViewController;

@synthesize repository;
@synthesize events;

- (id)initWithRepository:(Repository *)aRepository {
    self = [super initWithNibName:@"EventTableViewController" bundle:nil];
    if (self) {
        self.repository = aRepository;
        self.events = [[[NSMutableArray alloc] init] autorelease];
        isLoading = NO;
        complete = NO;
        pagesLoaded = 0;
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
    
    if (pagesLoaded == 0) {
        [self loadEvents];
    }
        
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
    // Return YES for supported orientations
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UIImageView* imageView = nil;
    UILabel* label = nil;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 55.0f, 55.0f)] autorelease];
        label = [[[UILabel alloc] initWithFrame:CGRectMake(57.0f, 2.0f, 0.0f, 0.0f)] autorelease];
        label.font = [UIFont systemFontOfSize:14.0f];
        label.numberOfLines = 0;
        label.lineBreakMode = UILineBreakModeWordWrap;
//        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
        imageView.tag = 1;
        label.tag = 2;
        
        [cell.contentView addSubview:imageView];
        [cell.contentView addSubview:label];
    } else {
        imageView = (UIImageView*)[cell.contentView viewWithTag:1];
        label = (UILabel*)[cell.contentView viewWithTag:2];
    }
    imageView.image = [UIImage imageNamed:@"gravatar-orgs.png"];
    // Configure the cell...
    GithubEvent* event = [events objectAtIndex:indexPath.row];
    label.text = event.text;
    CGSize size = [label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(tableView.frame.size.width - 57.0f, 200.0f) lineBreakMode:UILineBreakModeWordWrap];
    label.frame = CGRectMake(55.0f, 2.0f, 265.0f, size.height);
    [event.person loadImageIntoImageView:imageView];
    
    if (indexPath.row == events.count - 1) {
        [self loadEvents];
    }
    
    return cell;
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


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    GithubEvent* event = [events objectAtIndex:indexPath.row];
    CGSize size = [event.text sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(tableView.frame.size.width - 57.0f, 200.0f) lineBreakMode:UILineBreakModeWordWrap];
    CGFloat labelHeight = size.height + 4;
    return labelHeight > 55.0f ? labelHeight : 55.0f;
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}


-(void)loadEvents {
    if (!isLoading && !complete) {
        NSString* url = [NSString stringWithFormat:@"https://api.github.com/repos/%@/events?page=%d", repository.fullName, pagesLoaded + 1];
        isLoading = YES;
        [[NetworkProxy sharedInstance] loadStringFromURL:url block:^(int statusCode, NSDictionary* headerFields, id data) {
            if (statusCode == 200) {
                NSArray* eventArray = (NSArray*)data;
                if (eventArray.count == 0) {
                    complete = YES;
                    return;
                }
                for (NSDictionary* event in eventArray) {
                    [events addObject:[[[GithubEvent alloc] initWithJSON:event] autorelease]];
                }
                pagesLoaded++;
                isLoading = NO;
                [self.tableView reloadData];
            }
        }];
    }    
}
@end
