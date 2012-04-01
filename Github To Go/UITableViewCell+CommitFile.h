//
//  UITableViewCell+CommitFile.h
//  Github To Go
//
//  Created by Robert Panzer on 11.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommitFile.h"

@interface UITableViewCell (CommitFile)

+(UITableViewCell*) createCommitFileCellForTableView:(UITableView*)tableView;

-(void)bindCommitFile:(CommitFile*)commitFile tableView:(UITableView*)tableView;

+(CGFloat)tableView:(UITableView*)tableView heightForRowForCommitFile:(CommitFile*)commitFile;
@end
