//
//  BranchViewController.h
//  Github To Go
//
//  Created by Robert Panzer on 07.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "StringQueue.h"

@interface BranchViewController : UITableViewController {
    NSArray* commits;

    StringQueue* commitUrls; 
    
    BOOL isLoading;
}

@property(strong) NSArray* commits;
@property(strong) StringQueue* commitUrls;

-(id)initWithUrl:(NSString*)anUrl name:(NSString*)aName;

-(void)loadCommits:(int)count;

@end
