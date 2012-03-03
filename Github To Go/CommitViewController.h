//
//  CommitViewController.h
//  Github To Go
//
//  Created by Robert Panzer on 09.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Commit.h"
#import "Repository.h"

@interface CommitViewController : UITableViewController 

@property(strong) Commit* commit;
@property(strong) Repository* repository;
@property(strong) IBOutlet UITableViewCell* messageCell;
@property(strong) IBOutlet UITextView* messageTextView;
@property(strong) NSString* commitSha;
@property(strong) NSString* message;

-(id)initWithCommit:(Commit*)aCommit repository:(Repository*)aRepository;
@end
