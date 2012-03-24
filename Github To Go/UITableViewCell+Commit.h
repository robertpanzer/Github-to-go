//
//  UITableViewCell+Commit.h
//  Github To Go
//
//  Created by Robert Panzer on 24.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Commit.h"

@interface UITableViewCell (Commit)

+(UITableViewCell *)createCommitCellForTableView:(UITableView*)tableView;

-(void)bindCommit:(Commit *)commit tableView:(UITableView*)tableView;

+(CGFloat)tableView:(UITableView *)tableView heightForRowForCommit:(Commit *)commit;

@end
