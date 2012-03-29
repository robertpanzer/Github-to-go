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

static NSArray *keys;

static NSDictionary *titles;

static NSSet* isBool;

static NSSet* showDisclosure;

@interface PersonViewController ()

-(NSString*)stringValueForIndexPath:(NSIndexPath*)indexPath;

@end

@implementation PersonViewController

@synthesize person;
@synthesize imageView;
@synthesize nameLabel;
@synthesize tableHeader;
@synthesize letUserSelectCells;

+(void)initialize {
    keys = [NSArray arrayWithObjects:
            [NSArray arrayWithObjects:kName, kLogin, kEmail, kCreatedAt, kLocation, kBio, kHireable, nil],
            [NSArray arrayWithObjects:kPublicRepos, kPublicGists, nil],
            [NSArray arrayWithObjects:kFollowers, kFollowing, nil],
            nil];
    titles = [NSDictionary dictionaryWithObjectsAndKeys:
              NSLocalizedString(@"Name", @"Name"), kName,
              NSLocalizedString(@"Login", @"Login"), kLogin,
              NSLocalizedString(@"eMail", @"eMail"), kEmail,
              NSLocalizedString(@"Created at", @"Created at"), kCreatedAt,
              NSLocalizedString(@"Location", @"Location"), kLocation,
              NSLocalizedString(@"Biography", @"Biography"), kBio,
              NSLocalizedString(@"Hireable", @"Hireable"), kHireable,
              NSLocalizedString(@"Public repos", @"Public repos"), kPublicRepos,
              NSLocalizedString(@"Public gists", @"Public gists"), kPublicGists, 
              NSLocalizedString(@"Followers", @"Followers"), kFollowers,
              NSLocalizedString(@"Following", @"Following"), kFollowing,
              nil
              ];
    isBool = [[NSSet alloc] initWithObjects:kHireable, nil];
    showDisclosure = [NSSet setWithObjects:kFollowers, kFollowing, kPublicRepos, nil];
}

- (id)initWithPerson:(Person*)aPerson;
{
    self = [super initWithNibName:@"PersonViewController" bundle:nil];
    if (self) {
        self.person = aPerson;
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
    self.navigationItem.title = person.displayname;
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
    cell.detailTextLabel.text = [self stringValueForIndexPath:indexPath];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!letUserSelectCells) {
        return;
    }
    NSString *key = [[keys objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSString *title = [titles objectForKey:key];
    if ([key isEqualToString:kFollowers]) {
        letUserSelectCells = NO;
        NSString *url = [NSString stringWithFormat:@"%@/followers", person.url];
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
        letUserSelectCells = NO;
        NSString *url = [NSString stringWithFormat:@"%@/following", person.url];
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
    id value = [person valueForKey:key];
    
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
