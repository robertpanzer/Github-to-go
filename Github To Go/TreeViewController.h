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

@interface TreeViewController : UITableViewController {
    Tree* tree;
    
    NSString* commitSha;
    
    Repository* repository;
}

@property(strong) Tree* tree;
@property(strong, readonly) NSString* commitSha;
@property(strong, readonly) Repository* repository;

-(id)initWithUrl:(NSString*)anUrl absolutePath:(NSString*)anAbsolutePath commitSha:(NSString*)aCommitSha repository:(Repository*)aRepository;

-(IBAction)showTreeHistory:(id)sender;
@end
