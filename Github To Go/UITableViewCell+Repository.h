//
//  UITableViewCell+Repository.h
//  Github To Go
//
//  Created by Robert Panzer on 01.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Repository.h"

@interface UITableViewCell (Repository)

+(UITableViewCell *)createRepositoryCellForTableView:(UITableView*)tableView;

-(void)bindRepository:(Repository *)repository tableView:(UITableView*)tableView;

@end
