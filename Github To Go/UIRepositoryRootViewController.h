//
//  UIRepositoryRootViewController.h
//  Github To Go
//
//  Created by Robert Panzer on 29.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Repository.h"

#import "RepositoryViewController.h"
#import "BranchesBrowserViewController.h"

@interface UIRepositoryRootViewController : UIViewController {
    Repository* repository;
    
    RepositoryViewController* repositoryViewController;
    
    BranchesBrowserViewController* branchesBrowserViewController;
    
    UIView* headerView;
}

@property(strong) Repository* repository;
@property(strong) RepositoryViewController* repositoryViewController;
@property(strong) BranchesBrowserViewController* branchesBrowserViewController;
@property(strong) IBOutlet UIView* headerView;

- (id)initWithRepository:(Repository*)aRepository;

- (IBAction)selectedSegmentChanged:(id)sender;
@end
