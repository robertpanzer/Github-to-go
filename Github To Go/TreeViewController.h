//
//  TreeViewController.h
//  Github To Go
//
//  Created by Robert Panzer on 04.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tree.h"

@interface TreeViewController : UITableViewController {
    Tree* tree;
}

@property(strong) Tree* tree;

-(id)initWithUrl:(NSString*)anUrl name:(NSString*)aName;


@end
