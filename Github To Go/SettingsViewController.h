//
//  SettingsViewController.h
//  Github To Go
//
//  Created by Robert Panzer on 08.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UITableViewController {
    
    UITableViewCell* userNameCell;
    UITableViewCell* passwordCell;
    
    UITextField* usernameTextfield;
    UITextField* passwordTextfield;
    
}
@property(strong, nonatomic) IBOutlet UITableViewCell *accountSectionCell;
@property(strong, readonly) IBOutlet UITableViewCell* userNameCell;
@property(strong, readonly) IBOutlet UITableViewCell* passwordCell;
@property(strong, readonly) IBOutlet UITextField* usernameTextfield;
@property(strong, readonly) IBOutlet UITextField* passwordTextfield;

@property (weak, nonatomic) IBOutlet UILabel *successLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *accountCheckActivityIndicator;
          

- (IBAction)usernameChanged:(id)sender;
- (IBAction)passwordChanged:(id)sender;

-(void)validateAccountSettings;
@end
