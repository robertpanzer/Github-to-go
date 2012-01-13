//
//  CommitViewController.m
//  Github To Go
//
//  Created by Robert Panzer on 09.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CommitViewController.h"
#import "NetworkProxy.h"

@implementation CommitViewController

@synthesize commit;
@synthesize messageCell;
@synthesize messageTextView;

-(id)initWithUrl:(NSString*)anUrl andName:(NSString*)aName {
    self = [super initWithNibName:@"CommitViewController" bundle:nil];
    if (self) {
        self.navigationItem.title = aName;
        [[NetworkProxy sharedInstance] loadStringFromURL:anUrl block:^(int statusCode, id data) {
            if (statusCode == 200) {
                self.commit = [[[Commit alloc] initWithJSONObject:data] autorelease];
                [(UITableView*)self.view reloadData];
            }
        }];
    }
    return self;
}

- (void)dealloc {
    [commit release];
    [super dealloc];
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
    if (self.commit == nil) {
        return 0;
    } else {
        return 5;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (self.commit == nil) {
        return 0;
    } else if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 1;
    } else  if (section == 2) {
        return 3;
    } else if (section == 3) {
        return 3;
    } else if (section == 4) {
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.section == 0 && indexPath.row == 1) {
//        self.messageTextView.text = commit.message;
//        [self.messageTextView layoutSubviews];
//        self.messageTextView.frame = CGRectMake(0.0f, 0.0f, self.messageTextView.contentSize.width, self.messageTextView.contentSize.height);
//        self.messageCell.frame = CGRectMake(0.0f, 0.0f, self.messageTextView.contentSize.width, self.messageTextView.contentSize.height);
//        return self.messageCell;
//    }
    static NSString *CellIdentifier = @"Cell";
    static NSString *MessageCellIdentifier = @"MessageCell";
    
    UITableViewCell *cell = nil;
    if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:MessageCellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                           reuseIdentifier:MessageCellIdentifier] autorelease];
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 
                                           reuseIdentifier:CellIdentifier] autorelease];
        }
        
    }
    
    // Configure the cell...
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"SHA"; 
                    cell.detailTextLabel.text = commit.sha;
                    break;
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = commit.message; 
                    cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
                    cell.textLabel.numberOfLines = 0;

                    break;
                    
                default:
                    break;
            }
            break;
        case 2:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Deletions"; 
                    cell.detailTextLabel.text = [[[NSString alloc] initWithFormat:@"%d", commit.deletions] autorelease];
                    break;
                case 1:
                    cell.textLabel.text = @"Additions"; 
                    cell.detailTextLabel.text = [[[NSString alloc] initWithFormat:@"%d", commit.additions] autorelease];
                    break;
                case 2:
                    cell.textLabel.text = @"Total"; 
                    cell.detailTextLabel.text = [[[NSString alloc] initWithFormat:@"%d", commit.total] autorelease];
                    break;
                    
                default:
                    break;
            }
            break;
        case 3:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Name"; 
                    cell.detailTextLabel.text = commit.committer.name;
                    break;
                case 1:
                    cell.textLabel.text = @"EMail"; 
                    cell.detailTextLabel.text = commit.committer.email;
                    break;
                case 2:
                    cell.textLabel.text = @"Date"; 
                    cell.detailTextLabel.text = commit.committedDate;
                    break;
            }
            break;
        case 4:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Name"; 
                    cell.detailTextLabel.text = commit.author.name;
                    break;
                case 1:
                    cell.textLabel.text = @"EMail"; 
                    cell.detailTextLabel.text = commit.author.email;
                    break;
                case 2:
                    cell.textLabel.text = @"Date"; 
                    cell.detailTextLabel.text = commit.authoredDate;
                    break;
            }
            
        default:
            break;
    }
    
    return cell;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Base data";
        case 1:
            return @"Message";
        case 2:
            return @"Statistics";
        case 3:
            return @"Committer";
        case 4:
            return @"Author";
            
            
        default:
            break;
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
    
    NSLog(@"%@", ((UITableViewCell*)[tableView.visibleCells objectAtIndex:0]));
    
    UITableViewCell* tableViewCell = [tableView.visibleCells objectAtIndex:1];
    NSLog(@"%@", tableViewCell.textLabel);
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {

        UIFont* font = [UIFont systemFontOfSize:17.0f];
        
        CGSize size = [commit.message sizeWithFont:font constrainedToSize:CGSizeMake(tableView.frame.size.width - 40.0f/*280.0f*/, 1000.0f) lineBreakMode:UILineBreakModeWordWrap];
                
        CGFloat height = size.height + 10;

        return height > tableView.rowHeight ? height : tableView.rowHeight;
    } else {
        return tableView.rowHeight;
    }
}

@end
