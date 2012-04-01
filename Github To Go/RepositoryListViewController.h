//
//  RepositoryListViewController.h
//  Github To Go
//
//  Created by Robert Panzer on 01.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Repository.h"

@interface RepositoryListViewController : UITableViewController

@property (strong, nonatomic) NSArray *repositories;

-(id)initWithRepositories:(NSArray*)aRepositories;

@end
