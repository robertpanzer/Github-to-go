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

@interface EventTableViewController : UITableViewController 

@property(strong) Repository* repository;
@property(strong) HistoryList* eventHistory;
@property int pagesLoaded;
@property BOOL isLoading;
@property BOOL complete;
@property(strong) IBOutlet UITableViewCell* loadNextTableViewCell;

-(id)initWithRepository:(Repository*)aRepository;

-(id)initWithAllEvents;
@end
