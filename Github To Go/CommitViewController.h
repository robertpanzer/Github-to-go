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

@interface CommitViewController : UITableViewController {
    Commit* commit;
    
    UITableViewCell* messageCell;

    UITextView* messageTextview;
    
    Repository* repository;
}

@property(strong) Commit* commit;
@property(strong) Repository* repository;
@property(strong) IBOutlet UITableViewCell* messageCell;
@property(strong) IBOutlet UITextView* messageTextView;


-(id)initWithUrl:(NSString*)url andName:(NSString*)aName repository:(Repository*)aRepository;
@end
