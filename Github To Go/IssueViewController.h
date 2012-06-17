//
//  IssueViewController.h
//  Hub To Go
//
//  Created by Robert Panzer on 14.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Issue.h"

@interface IssueViewController : UITableViewController

@property(strong, nonatomic) Issue* issue;

-(id) initWithIssue:(Issue*)anIssue;

@end
