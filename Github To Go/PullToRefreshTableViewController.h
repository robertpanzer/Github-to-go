//
//  PullToRefreshTableViewControllerViewController.h
//  Github To Go
//
//  Created by Robert Panzer on 18.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PullToRefreshTableViewController : UITableViewController

@property BOOL reloadPossible;
@property BOOL isReloading;

-(void)reload;

-(void)willReload;
-(void)reloadDidFinish;

@end
