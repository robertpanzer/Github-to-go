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
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIView *tableHeader;
@property (nonatomic) BOOL letUserSelectCells;

-(id)initWithPerson:(Person*)aPerson;

@end
