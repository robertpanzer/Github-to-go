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

@property(strong, nonatomic) Commit* commit;
@property(strong, nonatomic) NSDictionary* comments;
@property(strong, nonatomic) Repository* repository;
@property(strong, nonatomic) IBOutlet UITableViewCell* messageCell;
@property(strong, nonatomic) IBOutlet UITextView* messageTextView;
@property(strong, nonatomic) NSString* commitSha;
@property(strong, nonatomic) NSString* message;
@property(nonatomic) BOOL letUserSelectCells;

-(id)initWithCommit:(Commit*)aCommit repository:(Repository*)aRepository;
@end
