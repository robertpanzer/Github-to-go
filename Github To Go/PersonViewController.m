//
//  PersonViewController.m
//  Github To Go
//
//  Created by Robert Panzer on 25.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PersonViewController.h"
#import "QuartzCore/QuartzCore.h"
#import "NetworkProxy.h"
#import "PersonListTableViewController.h"
#import "RepositoryListViewController.h"
#import "EventTableViewController.h"
#import "GithubEvent.h"
#import "HistoryList.h"
#import "RepositoryStorage.h"
#import "RPFollowPersonActivity.h"


static NSString *kName = @"name";
static NSString *kLogin = @"login";
static NSString *kEmail = @"email";
static NSString *kCreatedAt = @"createdAt";
static NSString *kLocation = @"location";
static NSString *kBio = @"bio";
static NSString *kHireable = @"hireable";

static NSString *kPublicRepos = @"publicRepos";
static NSString *kPublicGists = @"publicGists";

static NSString *kFollowers = @"followers";
static NSString *kFollowing = @"following";

static NSString *kEvents = @"events";

static NSArray *keys;

static NSDictionary *titles;

static NSArray* isBool;

static NSArray* showDisclosure;

static NSString *follow, *unfollow;



@interface PersonViewController ()

-(NSString*)stringValueForIndexPath:(NSIndexPath*)indexPath;

-(void)showPersonActions;

@end

@implementation PersonViewController

+(void)initialize {
    keys = @[
        @[kName, kLogin, kEmail, kCreatedAt, kLocation, kBio, kHireable],
        @[kPublicRepos, kPublicGists],
        @[kFollowers, kFollowing],
        @[kEvents]
    ];
    titles = @{
                kName: NSLocalizedString(@"Name", @"Name"),
                kLogin: NSLocalizedString(@"Login", @"Login"),
                kEmail: NSLocalizedString(@"eMail", @"eMail"),
                kCreatedAt: NSLocalizedString(@"Created at", @"Created at"),
                kLocation: NSLocalizedString(@"Location", @"Location"),
                kBio: NSLocalizedString(@"Biography", @"Biography"),
                kHireable: NSLocalizedString(@"Hireable", @"Hireable"),
                kPublicRepos: NSLocalizedString(@"Public repos", @"Public repos"),
                kPublicGists: NSLocalizedString(@"Public gists", @"Public gists"),
                kFollowers: NSLocalizedString(@"Followers", @"Followers"),
                kFollowing: NSLocalizedString(@"Following", @"Following"),
                kEvents: NSLocalizedString(@"Events", @"Events")
    };
    isBool = @[kHireable];
    showDisclosure = @[kFollowers, kFollowing, kPublicRepos, kEvents];
    
    follow = NSLocalizedString(@"Follow", @"Follow Action");
    unfollow = NSLocalizedString(@"Unfollow", @"Unfollow Action");
    
}

- (id)initWithPerson:(Person*)aPerson;
{
    self = [super initWithNibName:@"PersonViewController" bundle:nil];
    if (self) {
        _person = aPerson;

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.tableHeaderView = self.tableHeader;

    self.imageView.layer.cornerRadius = 10.0f;
    self.imageView.layer.borderWidth = 1.0f;
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.nameLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    self.navigationItem.title = self.person.displayname;
    
    UIImage *backgroundImage = [UIImage imageNamed:@"background"];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    self.tableView.backgroundView = backgroundImageView;

    if (NSClassFromString(@"UIActivityViewController") != NULL) {
        self.shareUrlController = [[RPShareUrlController alloc] initWithUrl:[NSString stringWithFormat:@"http://github.com/%@", _person.login]
                                                                  title:_person.displayname
                                                         viewController:self];
        [self.shareUrlController addActivity:[[RPFollowPersonActivity alloc] initWithPerson:self.person]];
        self.navigationItem.rightBarButtonItem = self.shareUrlController.barButtonItem;
        
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showPersonActions)];
    }

}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.person loadImageIntoImageView:self.imageView];
    self.nameLabel.text = self.person.displayname;
    self.letUserSelectCells = YES;
    

}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setNameLabel:nil];
    [self setTableHeader:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return keys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[keys objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    NSString *key = [[keys objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:13.0f];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13.0f];
    }
    cell.accessoryType = [showDisclosure containsObject:key] ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    if ([[keys objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] == kBio) {
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
    } else {
        cell.detailTextLabel.numberOfLines = 1;
        cell.detailTextLabel.textAlignment = UITextAlignmentRight;
    }

    cell.textLabel.text = [titles objectForKey:key];
    if (key != kEvents) {
        cell.detailTextLabel.text = [self stringValueForIndexPath:indexPath];
    } else {
        cell.detailTextLabel.text = nil;
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.letUserSelectCells) {
        return;
    }
    NSString *key = [[keys objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSString *title = [titles objectForKey:key];
    if ([key isEqualToString:kFollowers]) {
        self.letUserSelectCells = NO;
        NSString *url = [NSString stringWithFormat:@"%@/followers", self.person.url];
        [[NetworkProxy sharedInstance] loadStringFromURL:url block:^(int statusCode, NSDictionary *aHeaderFields, id data) {
            if (statusCode == 200) {
                NSMutableArray *persons = [NSMutableArray array];
                for (NSDictionary *jsonObject in data) {
                    [persons addObject:[[Person alloc] initWithJSONObject:jsonObject]];
                    
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    PersonListTableViewController *personListTableViewController = [[PersonListTableViewController alloc] initWithPersons:persons title:title];
                    [self.navigationController pushViewController:personListTableViewController animated:YES];
                });
            }
        }];
    } else if ([key isEqualToString:kFollowing]) {
        self.letUserSelectCells = NO;
        NSString *url = [NSString stringWithFormat:@"%@/following", self.person.url];
        [[NetworkProxy sharedInstance] loadStringFromURL:url block:^(int statusCode, NSDictionary *aHeaderFields, id data) {
            if (statusCode == 200) {
                NSMutableArray *persons = [NSMutableArray array];
                for (NSDictionary *jsonObject in data) {
                    [persons addObject:[[Person alloc] initWithJSONObject:jsonObject]];
                    
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    PersonListTableViewController *personListTableViewController = [[PersonListTableViewController alloc] initWithPersons:persons title:title];
                    [self.navigationController pushViewController:personListTableViewController animated:YES];
                });
            }
        }];
    } else if ([key isEqualToString:kPublicRepos]) {
        self.letUserSelectCells = NO;
        NSString *url = [NSString stringWithFormat:@"%@/repos", self.person.url];
        [[NetworkProxy sharedInstance] loadStringFromURL:url block:^(int statusCode, NSDictionary *aHeaderFields, id data) {
            if (statusCode == 200) {
                NSMutableArray *repos = [NSMutableArray array];
                for (NSDictionary *jsonObject in data) {
                    [repos addObject:[[Repository alloc] initFromJSONObject:jsonObject]];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    RepositoryListViewController *repoListTableViewController = [[RepositoryListViewController alloc] initWithRepositories:repos];
                    [self.navigationController pushViewController:repoListTableViewController animated:YES];
                });
            }
        }];
    } else if ([key isEqualToString:kEvents]) {
        self.letUserSelectCells = NO;
        NSString *url = [NSString stringWithFormat:@"%@/events/public", self.person.url];
        EventTableViewController *eventListTableViewController = [[EventTableViewController alloc] initWithUrl:url];
        [self.navigationController pushViewController:eventListTableViewController animated:YES];

    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* keyPath = [[keys objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if ([keyPath isEqualToString:kBio]) {
        UIFont* font = [UIFont systemFontOfSize:13.0f];
        NSString* value = [self stringValueForIndexPath:indexPath];
        if (value != nil) {
            CGSize size = [value sizeWithFont:font constrainedToSize:CGSizeMake(tableView.frame.size.width - 110.0f, 1000.0f) lineBreakMode:UILineBreakModeWordWrap];
            
            CGFloat height = size.height + 10;
            
            return height > tableView.rowHeight ? height : tableView.rowHeight;
        }
    }
    return self.tableView.rowHeight;
}

-(NSString*)stringValueForIndexPath:(NSIndexPath*)indexPath {
    NSString *key = [[keys objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    id value = [self.person valueForKeyPath:key];
    
    if (value == [NSNull null]) {
        return nil;
    } else if ([value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSArray class]]) {
        return [NSString stringWithFormat:@"%d", [value count]];
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

-(void)showPersonActions {
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
    if ([[RepositoryStorage sharedStorage].followedPersons objectForKey:self.person.login] == nil) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Follow", @"Follow")];
    } else {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Unfollow", @"Unfollow")];
    }
    
    [actionSheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString* titleClicked = [actionSheet buttonTitleAtIndex:buttonIndex];
    NSString* url = [NSString stringWithFormat:@"https://api.github.com/user/following/%@", self.person.login];
    if ([[RepositoryStorage sharedStorage].followedPersons objectForKey:self.person.login] == nil) {
        [[NetworkProxy sharedInstance] loadStringFromURL:url verb:@"PUT" block:^(int status, NSDictionary* headerFields, id data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == 204) {
                    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:titleClicked message:@"User is being followed now" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [alertView show];
                    [[RepositoryStorage sharedStorage].followedPersons setObject:self.person forKey:self.person.login];
                } else {
                    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:titleClicked message:@"Following user failed" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [alertView show];
                }
            });
            [[RepositoryStorage sharedStorage] loadFollowed];
        } ];
    } else if ([unfollow isEqualToString:titleClicked]) {
        [[NetworkProxy sharedInstance] loadStringFromURL:url verb:@"DELETE" block:^(int status, NSDictionary* headerFields, id data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == 204) {
                    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:titleClicked message:@"User is no longer followed now" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [alertView show];
                    [[RepositoryStorage sharedStorage].followedPersons removeObjectForKey:self.person.login];
                } else {
                    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:titleClicked message:@"Stopping to follow user failed" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [alertView show];
                }
            });
            [[RepositoryStorage sharedStorage] loadFollowed];
        } ];
    }
    
}


@end
