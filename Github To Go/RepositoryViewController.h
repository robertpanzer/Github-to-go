//
//  RepositoryViewController.h
//  Github To Go
//
//  Created by Robert Panzer on 06.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Repository.h"

@interface RepositoryViewController : UITableViewController {
    Repository* repository;
    
}

@property(strong) Repository* repository;

-(id)initWithRepository:(Repository*)repository;

@end
