//
//  PersonListTableViewController.m
//  Github To Go
//
//  Created by Robert Panzer on 28.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PersonListTableViewController.h"
#import "UITableViewCell+Person.h"
#import "PersonViewController.h"
#import "NetworkProxy.h"

@interface PersonListTableViewController ()

@end

@implementation PersonListTableViewController

@synthesize persons, title;
@synthesize letUserSelectCells;

- (id)initWithPersons:(NSArray*)aPersons title:(NSString*)aTitle
{
    self = [super initWithNibName:@"PersonListTableViewController" bundle:nil];
    if (self) {
        self.persons = aPersons;
        self.title = aTitle;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.title = self.title;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.letUserSelectCells = YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return persons.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Person *person = [persons objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [UITableViewCell createSimplePersonCellForTableView:self.tableView];
    [cell bindPerson:person tableView:self.tableView];
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.letUserSelectCells) {
        self.letUserSelectCells = NO;
        Person *person = [persons objectAtIndex:indexPath.row];
        [[NetworkProxy sharedInstance] loadStringFromURL:person.url block:^(int statusCode, NSDictionary *aHeaderFields, id data) {
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

@end
