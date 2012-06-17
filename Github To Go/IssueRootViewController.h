//
//  IssueRootViewController.h
//  Hub To Go
//
//  Created by Robert Panzer on 17.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RPFlickViewController.h"
#import "Issue.h"

@interface IssueRootViewController : RPFlickViewController

@property(strong, nonatomic) Issue* issue;

- (id)initWithIssue:(Issue*)anIssue;

@end
