//
//  CommitViewController.m
//  Github To Go
//
//  Created by Robert Panzer on 09.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CommitViewController.h"
#import "NetworkProxy.h"
#import "CommitFile.h"
#import "FileDiffViewController.h"
#import "BlobViewController.h"

@implementation CommitViewController

@synthesize commit;
@synthesize messageCell;
@synthesize messageTextView;
@synthesize repository;
@synthesize commitSha;
@synthesize message;

-(id)initWithCommit:(Commit*)aCommit repository:(Repository*)aRepository {
    self = [super initWithNibName:@"CommitViewController" bundle:nil];
    if (self) {
        self.repository = aRepository;
        self.commitSha = aCommit.sha;
        self.message = aCommit.message;
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

    self.navigationItem.title = self.message;
    NSString* commitUrl = [NSString stringWithFormat:@"https://api.github.com/repos/%@/commits/%@", self.repository.fullName, self.commitSha];
    [[NetworkProxy sharedInstance] loadStringFromURL:commitUrl block:^(int statusCode, NSDictionary* headerFields, id data) {
        if (statusCode == 200) {
            self.commit = [[Commit alloc] initWithJSONObject:data repository:self.repository];
            [(UITableView*)self.view reloadData];
        }
    }];
    NSString* commentsUrl = [NSString stringWithFormat:@"https://api.github.com/repos/%@/commits/%@/comments", repository.fullName, self.commitSha];
    NSLog(@"Comments URL: %@", commentsUrl);
    [[NetworkProxy sharedInstance] loadStringFromURL:commentsUrl block:^(int statusCode, NSDictionary* headerFields, id data) {
        if (statusCode == 200) {
            NSLog(@"Comments %@", data);
        }
    }];
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
        return 6;
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
        return 4;
    } else if (section == 4) {
        return 3;
    } else if (section == 5) {
        return commit.changedFiles.count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *CellIdentifier = @"Cell";
    static NSString *MessageCellIdentifier = @"MessageCell";
    static NSString *FilenameCellIdentifier = @"FilenameCell";
    static NSString *imageCellIdentifier = @"ImageCell";
    
    UITableViewCell *cell = nil;
    if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:MessageCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                           reuseIdentifier:MessageCellIdentifier];
            cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
        }
    } else if (indexPath.section == 5) {
        cell = [tableView dequeueReusableCellWithIdentifier:FilenameCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                           reuseIdentifier:FilenameCellIdentifier];
            cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
        }
    } else if (indexPath.section == 3 && indexPath.row == 3) {
        cell = [tableView dequeueReusableCellWithIdentifier:imageCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                           reuseIdentifier:imageCellIdentifier];
            cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
            cell.imageView.image = [UIImage imageNamed:@"gravatar-orgs.png"];
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 
                                           reuseIdentifier:CellIdentifier];
            cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0f];
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
                    cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%d", commit.deletions];
                    break;
                case 1:
                    cell.textLabel.text = @"Additions"; 
                    cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%d", commit.additions];
                    break;
                case 2:
                    cell.textLabel.text = @"Total"; 
                    cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%d", commit.total];
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
                case 3:
                    cell.textLabel.text = @"Image"; 
                    if (commit.committer.avatarUrl != nil) {
                        [[NetworkProxy sharedInstance] loadStringFromURL:commit.committer.avatarUrl block:^(int statusCode, NSDictionary *aHeaderFields, id data) {
                            if (statusCode == 200) {
                                cell.imageView.image = data;
                            }
                        }];
                    }
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
            break;
        case 5: {
            CommitFile* commitFile = [self.commit.changedFiles objectAtIndex:indexPath.row];
            
            cell.textLabel.text = commitFile.fileName;
        }
            break;
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
        case 5:
            return @"Files";
        default:
            return @"???";
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 5) {
        CommitFile* commitFile = [self.commit.changedFiles objectAtIndex:indexPath.row];
//        FileDiffViewController* fileDiffViewController = [[FileDiffViewController alloc] initWithCommitFile:commitFile];
//        [self.navigationController pushViewController:fileDiffViewController animated:YES];
          
        BlobViewController* blobViewController = [[BlobViewController alloc] initWithCommitFile:commitFile];
        [self.navigationController pushViewController:blobViewController animated:YES];
        
//        [commitFile loadFile];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        UIFont* font = [UIFont systemFontOfSize:14.0f];
        
        CGSize size = [commit.message sizeWithFont:font constrainedToSize:CGSizeMake(tableView.frame.size.width - 40.0f/*280.0f*/, 1000.0f) lineBreakMode:UILineBreakModeWordWrap];
                
        CGFloat height = size.height + 10;

        return height > tableView.rowHeight ? height : tableView.rowHeight;
    } else if (indexPath.section == 5) {
        UIFont* font = [UIFont systemFontOfSize:14.0f];

        CommitFile* commitFile = [commit.changedFiles objectAtIndex:indexPath.row];
        CGSize size = [commitFile.fileName sizeWithFont:font constrainedToSize:CGSizeMake(tableView.frame.size.width - 40.0f/*280.0f*/, 1000.0f) lineBreakMode:UILineBreakModeWordWrap];
        
        CGFloat height = size.height + 10;
        
        return height > tableView.rowHeight ? height : tableView.rowHeight;
    } else {
        return tableView.rowHeight;
    }
}

@end
