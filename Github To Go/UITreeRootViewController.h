//
//  UITreeRootViewController.h
//  Github To Go
//
//  Created by Robert Panzer on 30.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Repository.h"
#import "Commit.h"
#import "TreeViewController.h"
#import "BranchViewController.h"

@interface UITreeRootViewController : UIViewController {
    UIView* headerView;
    
    NSString* treeUrl;
    
    NSString* absolutePath;

    NSString* branchName;
    
    Commit* commit;
    
    Repository* repository;
    
    TreeViewController* treeViewController;
    
    BranchViewController* branchViewController;
}

@property(strong) IBOutlet UIView* headerView;
@property(strong) NSString* treeUrl;
@property(strong) NSString* absolutePath;
@property(strong) NSString* branchName;
@property(strong) Commit* commit;
@property(strong) Repository* repository;

-(id)initWithUrl:(NSString*)aTreeUrl absolutePath:(NSString*)anAbsolutePath commit:(Commit *)aCommit repository:(Repository *)aRepository branchName:(NSString*)aBranchName;

- (IBAction)selectedSegmentChanged:(id)sender;

@end
