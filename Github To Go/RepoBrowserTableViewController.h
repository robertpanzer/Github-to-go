//
//  RepoBrowserTableViewController.h
//  TabBarTest
//
//  Created by Robert Panzer on 30.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Repository.h"

@interface RepoBrowserTableViewController : UITableViewController {
    NSArray* myRepos;
    NSArray* watchedRepos;
}

- (IBAction)onFetchRepos;

-(void)showMasterBranch:(Repository*)repository;

@property(strong) NSArray* myRepos;
@property(strong) NSArray* watchedRepos;

@end
