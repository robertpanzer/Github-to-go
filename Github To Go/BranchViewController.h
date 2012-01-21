//
//  BranchViewController.h
//  Github To Go
//
//  Created by Robert Panzer on 07.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Repository.h"
#import "Branch.h"
#import "StringQueue.h"
#import "CommitHistoryList.h"


@interface BranchViewController : UITableViewController {
    CommitHistoryList* commitHistoryList;
    
    NSMutableSet* missingCommits; 
    
    Repository* repository;
    
    Branch* branch;
    
    BOOL isLoading;
}

@property(strong) NSMutableSet* missingCommits;
@property(strong) Repository* repository;
@property(strong) Branch* branch;

-(id)initWithRepository:(Repository*)aRepository andBranch:(Branch*)aBranch;

//-(void)loadCommits:(int)count;

@end
