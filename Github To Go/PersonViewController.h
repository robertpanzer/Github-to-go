//
//  PersonViewController.h
//  Github To Go
//
//  Created by Robert Panzer on 25.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"

@interface PersonViewController : UITableViewController

@property(strong, nonatomic) Person *person;

-(id)initWithPerson:(Person*)aPerson;

@end
