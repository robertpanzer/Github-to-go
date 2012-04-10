//
//  SettingsViewController.m
//  Github To Go
//
//  Created by Robert Panzer on 08.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"

#import "Settings.h"
#import "NetworkProxy.h"

@interface SettingsViewController()

-(void)showAuthenticationSuccess:(BOOL)success;

@end

@implementation SettingsViewController

@synthesize accountSectionCell;
@synthesize userNameCell;
@synthesize passwordCell;
@synthesize usernameTextfield;
@synthesize passwordTextfield;
@synthesize successLabel;
@synthesize accountCheckActivityIndicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Settings", @"Settings");
        self.tabBarItem.image = [UIImage imageNamed:@"settings"];
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
    self.usernameTextfield.text = [Settings sharedInstance].username;
    self.passwordTextfield.text = [Settings sharedInstance].password;
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    UILabel *footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 20)];
    footerLabel.text = [NSString stringWithFormat:@"Version: %@", version];
    footerLabel.backgroundColor = [UIColor clearColor];
    footerLabel.textAlignment = UITextAlignmentCenter;
    footerLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    footerLabel.font = [UIFont systemFontOfSize:13.0f];
    self.tableView.tableFooterView = footerLabel;
            
    UIImage *backgroundImage = [UIImage imageNamed:@"background"];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    self.tableView.backgroundView = backgroundImageView;
}

- (void)viewDidUnload
{
    accountSectionCell = nil;
    [self setAccountSectionCell:nil];
    [self setSuccessLabel:nil];
    [self setAccountCheckActivityIndicator:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.accountCheckActivityIndicator.hidden = YES;
    self.successLabel.hidden = YES;
    if ([Settings sharedInstance].passwordValidated != nil) {
        [self showAuthenticationSuccess:[[Settings sharedInstance].passwordValidated boolValue]];
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
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return self.accountSectionCell;
        } else if (indexPath.row == 1) {
            self.usernameTextfield.text = [Settings sharedInstance].username;
            return self.userNameCell;
        } else if (indexPath.row == 2) {
            self.passwordTextfield.text = [Settings sharedInstance].password;
            return self.passwordCell;
        }
    }
    
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self.usernameTextfield becomeFirstResponder];
        } else if (indexPath.row == 1) {
            [self.passwordTextfield becomeFirstResponder];
        }
    }
}

#pragma mark - Editing actions

- (void)usernameChanged:(id)sender {
    UITextField* textfield = (UITextField*)sender;
    [Settings sharedInstance].username = textfield.text;
    [sender resignFirstResponder];
    [(UITableView*)self.view reloadData];
    [self validateAccountSettings];
}

-(void)passwordChanged:(id)sender {
    UITextField* textfield = (UITextField*)sender;
    [Settings sharedInstance].password = textfield.text;
    [sender resignFirstResponder];
    [self validateAccountSettings];
}

-(void)validateAccountSettings {
    self.successLabel.hidden = YES;
    self.accountCheckActivityIndicator.hidden = NO;
    [self.accountCheckActivityIndicator startAnimating];
    NSString *url = [NSString stringWithFormat:@"https://api.github.com/users/%@", [Settings sharedInstance].username];
   [[NetworkProxy sharedInstance] loadStringFromURL:url block:^(int statusCode, NSDictionary *aHeaderFields, id data) {
       dispatch_async(dispatch_get_main_queue(), ^{
           if (statusCode == 200) {
               self.successLabel.hidden = NO;
               self.successLabel.text = @"\u2713";
               self.successLabel.textColor = [UIColor greenColor];
               self.accountCheckActivityIndicator.hidden = YES;
           } else {
               self.successLabel.hidden = NO;
               self.successLabel.text = @"\u2717";
               self.successLabel.textColor = [UIColor redColor];
               self.accountCheckActivityIndicator.hidden = YES;
           }
       });
   } errorBlock:^(NSError *error) {
       dispatch_async(dispatch_get_main_queue(), ^{
           self.successLabel.hidden = NO;
           self.successLabel.text = @"\u2717";
           self.successLabel.textColor = [UIColor redColor];
           self.accountCheckActivityIndicator.hidden = YES;
       });
   }]; 
}

-(void)showAuthenticationSuccess:(BOOL)success {
    if (success) {
        self.successLabel.text = @"\u2713";
        self.successLabel.textColor = [UIColor greenColor];
    } else {
        self.successLabel.text = @"\u2717";
        self.successLabel.textColor = [UIColor redColor];
    }
    self.successLabel.hidden = NO;
    self.accountCheckActivityIndicator.hidden = YES;
    
}
@end
