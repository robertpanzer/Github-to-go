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
#import "Tree.h"

@interface BranchViewController : UITableViewController {
    CommitHistoryList* commitHistoryList;
    
    NSString* absolutePath;
    
    Repository* repository;
    
    Branch* branch;
    
    NSString* commitSha;
    
    BOOL isLoading;
    
    BOOL isComplete;
}

@property(strong) Repository* repository;
@property(strong) Branch* branch;
@property(strong, readonly) NSString* absolutePath;
@property(strong, readonly) NSString* commitSha;

-(id)initWithRepository:(Repository*)aRepository andBranch:(Branch*)aBranch;

-(id)initWithTree:(Tree*)tree commitSha:(NSString*)aCommitSha repository:(Repository*)aRepository;

-(id)initWithBlob:(Blob*)blob commitSha:(NSString*)aCommitSha repository:(Repository*)aRepository;


@end
