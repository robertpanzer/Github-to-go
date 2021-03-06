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
#import "PullRequest.h"

@interface BranchViewController : UITableViewController <UISearchBarDelegate> {
    CommitHistoryList* commitHistoryList;
    
    NSString* absolutePath;
    
    Repository* repository;
    
    Branch* branch;
    
    NSString* commitSha;
    
    BOOL isLoading;
    
    BOOL isComplete;
    
    BOOL isSearchResult;
    
    BOOL letUserSelectCells;
    
    UISearchBar* searchBar;
    
    NSString *fullUrl;
}

@property(strong) Repository* repository;
@property(strong) Branch* branch;
@property(strong, readonly) NSString* absolutePath;
@property(strong, readonly) NSString* commitSha;
@property(strong) UISearchBar* searchBar;
@property(strong) IBOutlet UITableViewCell* loadNextTableViewCell;
@property(strong, nonatomic) NSString *fullUrl;

-(id)initWithRepository:(Repository*)aRepository andBranch:(Branch*)aBranch;

-(id)initWithAbsolutePath:(NSString*)anAbsolutePath commitSha:(NSString*)aCommitSha repository:(Repository*)aRepository;

-(id)initWithCommitHistoryList:(CommitHistoryList*)aCommitHistoryList repository:(Repository*)aRepository branch:(Branch*)aBranch;

-(id)initWithPullRequest:(PullRequest*)aPullRequest;

-(void)loadCommits;


@end
