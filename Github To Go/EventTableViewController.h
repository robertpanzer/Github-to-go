//
//  EventTableViewController.h
//  Github To Go
//
//  Created by Robert Panzer on 09.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Repository.h"

@interface EventTableViewController : UITableViewController {
    
    Repository* repository;
    
    NSMutableArray* events;
    
    int pagesLoaded;
    
    BOOL isLoading;
    
    BOOL complete;
    
}

@property(strong) Repository* repository;
@property(strong) NSMutableArray* events;

-(id)initWithRepository:(Repository*)aRepository;

@end
