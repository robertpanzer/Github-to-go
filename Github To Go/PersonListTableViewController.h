//
//  PersonListTableViewController.h
//  Github To Go
//
//  Created by Robert Panzer on 28.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonListTableViewController : UITableViewController

@property(strong, nonatomic) NSArray *persons;
@property(strong, nonatomic) NSString *title;
@property(nonatomic) BOOL letUserSelectCells;
-(id)initWithPersons:(NSArray*)aPersons title:(NSString*)aTitle;
@end
