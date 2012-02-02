//
//  TreeViewController.h
//  Github To Go
//
//  Created by Robert Panzer on 04.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tree.h"
#import "Repository.h"

@interface TreeViewController : UITableViewController <UIActionSheetDelegate> {
    Tree* tree;
    
    Commit* commit;
    
    NSString* branchName;
    
    Repository* repository;

    NSString* absolutePath;
}

@property(strong) Tree* tree;
@property(strong, readonly) Commit* commit;
@property(strong, readonly) Repository* repository;
@property(strong) NSString* branchName;
@property(strong) NSString* absolutePath;

-(id)initWithTree:(Tree*)aTree absolutePath:(NSString*)anAbsolutePath commit:(Commit*)aCommit repository:(Repository*)aRepository branchName:(NSString*)aBranchName;

-(IBAction)showTreeHistory:(id)sender;

-(IBAction)offerTreeActions:(id)sender;
@end
