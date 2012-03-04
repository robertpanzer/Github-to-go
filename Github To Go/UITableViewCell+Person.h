//
//  UITableViewCell+Person.h
//  Github To Go
//
//  Created by Robert Panzer on 04.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"

@interface UITableViewCell (Person)

+(UITableViewCell *)createPersonCell:(NSString*)identifier tableView:(UITableView*)tableView;

-(void)bindPerson:(Person *)person role:(NSString*)role tableView:(UITableView*)tableView;

@end
