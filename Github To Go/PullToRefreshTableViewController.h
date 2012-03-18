//
//  PullToRefreshTableViewControllerViewController.h
//  Github To Go
//
//  Created by Robert Panzer on 18.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReloadLabel : UIView

@property(strong, nonatomic) UILabel *label;
@property(strong, nonatomic) NSString *text;
@end


@interface PullToRefreshTableViewController : UITableViewController

@property(strong, nonatomic) ReloadLabel *reloadLabel;

@property CGFloat lastSwipeOffset;
@property BOOL reloadPossible;

-(void)reload;
@end
