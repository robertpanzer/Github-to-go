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

@interface EventTableViewController : UITableViewController {
    
    Repository* repository;
    
    HistoryList* eventHistory;
    
    int pagesLoaded;
    
    BOOL isLoading;
    
    BOOL complete;
    
}

@property(strong) Repository* repository;
@property(strong) HistoryList* eventHistory;

-(id)initWithRepository:(Repository*)aRepository;

@end
