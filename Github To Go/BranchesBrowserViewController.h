//
//  BranchesBrowserViewController.h
//  Github To Go
//
//  Created by Robert Panzer on 06.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BranchesBrowserViewController : UITableViewController {
    NSArray* branches;
}

@property(strong) NSArray* branches;

-(id)initWithUrl:(NSString*)anUrl name:(NSString*)aName;

@end
