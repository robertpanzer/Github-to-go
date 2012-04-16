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
#import "CommitComment.h"
#import "BlobViewController.h"
#import "PersonViewController.h"
#import "UITableViewCell+Person.h"
#import "UITableViewCell+CommitFile.h"

@implementation CommitViewController

@synthesize commit;
@synthesize messageCell;
@synthesize messageTextView;
@synthesize repository;
@synthesize commitSha;
@synthesize message;
@synthesize letUserSelectCells;
@synthesize comments;

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

    UIImage *backgroundImage = [UIImage imageNamed:@"background"];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    self.tableView.backgroundView = backgroundImageView;

    self.navigationItem.title = self.message;
    NSString* commitUrl = [NSString stringWithFormat:@"https://api.github.com/repos/%@/commits/%@", self.repository.fullName, self.commitSha];
    [[NetworkProxy sharedInstance] loadStringFromURL:commitUrl block:^(int statusCode, NSDictionary* headerFields, id data) {
        if (statusCode == 200) {
            self.commit = [[Commit alloc] initWithJSONObject:data repository:self.repository];
            dispatch_async(dispatch_get_main_queue(), ^() {
                [self.tableView reloadData];
            });
        }
    }];
    NSString* commentsUrl = [NSString stringWithFormat:@"https://api.github.com/repos/%@/commits/%@/comments", repository.fullName, self.commitSha];
    [[NetworkProxy sharedInstance] loadStringFromURL:commentsUrl block:^(int statusCode, NSDictionary* headerFields, id data) {
        if (statusCode == 200) {
            NSMutableDictionary *newComments = [NSMutableDictionary dictionary];
            for (NSDictionary *jsonObject in data) {
                CommitComment *comment = [[CommitComment alloc] initWithJSONObject:jsonObject];
                NSMutableArray *commentsForFile = [newComments objectForKey:comment.path];
                if (commentsForFile == nil) {
                    commentsForFile = [NSMutableArray array];
                    [newComments setObject:commentsForFile forKey:comment.path];
                }
                [commentsForFile addObject:comment];
            }
            self.comments = newComments;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
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
    self.letUserSelectCells = YES;
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

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (self.commit == nil) {
        return 0;
    } else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (self.commit == nil) {
        return 0;
    } else if (section == 0) {
        return 7;
    } else if (section == 1) {
        return commit.changedFiles.count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *CellIdentifier = @"Cell";
    static NSString *MessageCellIdentifier = @"MessageCell";
    
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:MessageCellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                              reuseIdentifier:MessageCellIdentifier];
                cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
                cell.textLabel.numberOfLines = 0;
                cell.textLabel.font = [UIFont systemFontOfSize:13.0f];
            }
            cell.textLabel.text = commit.message; 
            cell.detailTextLabel.text = nil; 
            return cell;
        } else if (indexPath.row == 2) {
            cell = [UITableViewCell createPersonCellForTableView:self.tableView];
            [cell bindPerson:commit.committer role:@"Committer" tableView:self.tableView];
            return cell;
        } else if (indexPath.row == 3) {
            cell = [UITableViewCell createPersonCellForTableView:self.tableView];
            [cell bindPerson:commit.author role:@"Author" tableView:self.tableView];
            return cell;
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 
                                              reuseIdentifier:CellIdentifier];
                cell.detailTextLabel.font = [UIFont systemFontOfSize:13.0f];
                cell.textLabel.font = [UIFont systemFontOfSize:13.0f];
            }
            switch (indexPath.row) {
                case 1:
                    cell.textLabel.text = @"SHA"; 
                    cell.detailTextLabel.text = self.commit.sha;
                    break;
                case 4:
                    cell.textLabel.text = @"Deletions"; 
                    cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%d", commit.deletions];
                    break;
                case 5:
                    cell.textLabel.text = @"Additions"; 
                    cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%d", commit.additions];
                    break;
                case 6:
                    cell.textLabel.text = @"Total"; 
                    cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%d", commit.total];
                    break;
            }
            return cell;
        }
    } else if (indexPath.section == 1) {
        cell = [UITableViewCell createCommitFileCellForTableView:tableView];
        CommitFile* commitFile = [self.commit.changedFiles objectAtIndex:indexPath.row];
        [cell bindCommitFile:commitFile comments:[self.comments objectForKey:commitFile.fileName] tableView:self.tableView];
        return cell;
    }
    return nil;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return nil;
        case 1:
            return @"Files";
        default:
            return @"???";
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.letUserSelectCells) {
        if (indexPath.section == 0) {
            if (indexPath.row == 2 || indexPath.row == 3) {
                self.letUserSelectCells = NO;
                NSString *url = nil;
                if (indexPath.row == 2) {
                    url = [NSString stringWithFormat:@"https://api.github.com/users/%@", commit.committer.login];
                } else if (indexPath.row == 3) {
                    url = [NSString stringWithFormat:@"https://api.github.com/users/%@", commit.author.login];
                }
                [[NetworkProxy sharedInstance] loadStringFromURL:url block:^(int statusCode, NSDictionary *aHeaderFields, id data) {
                    if (statusCode == 200) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            Person *person = [[Person alloc] initWithJSONObject:data];
                            PersonViewController *pwc = [[PersonViewController alloc] initWithPerson:person];
                            [self.navigationController pushViewController:pwc animated:YES];
                        });
                    }
                }];
            }
        } else if (indexPath.section == 1) {
            self.letUserSelectCells = NO;
            CommitFile* commitFile = [self.commit.changedFiles objectAtIndex:indexPath.row];
            
            BlobViewController* blobViewController = [[BlobViewController alloc] initWithCommitFile:commitFile comments:[self.comments objectForKey:commitFile.fileName]];
            [self.navigationController pushViewController:blobViewController animated:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        UIFont* font = [UIFont systemFontOfSize:13.0f];
        
        CGSize size = [commit.message sizeWithFont:font constrainedToSize:CGSizeMake(tableView.frame.size.width - 118.0f/*280.0f*/, 1000.0f) lineBreakMode:UILineBreakModeWordWrap];
                
        CGFloat height = size.height + 10;

        return height > tableView.rowHeight ? height : tableView.rowHeight;
    } else if (indexPath.section == 1) {
        CommitFile* commitFile = [commit.changedFiles objectAtIndex:indexPath.row];
        return [UITableViewCell tableView:tableView heightForRowForCommitFile:commitFile comments:[self.comments objectForKey:commitFile.fileName]];
    } else {
        return tableView.rowHeight;
    }
}

@end
