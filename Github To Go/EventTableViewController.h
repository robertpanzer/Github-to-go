//
//  EventTableViewController.h
//  Github To Go
//
//  Created by Robert Panzer on 09.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Repository.h"
#import "HistoryList.h"
#import "PullToRefreshTableViewController.h"

@interface EventTableViewController : PullToRefreshTableViewController

@property(strong, nonatomic) Repository* repository;
@property(strong, nonatomic) HistoryList* eventHistory;
@property int pagesLoaded;
@property BOOL isLoading;
@property BOOL complete;
@property(strong, nonatomic) IBOutlet UITableViewCell* loadNextTableViewCell;

-(id)initWithRepository:(Repository*)aRepository;

-(id)initWithAllEvents;
@end
