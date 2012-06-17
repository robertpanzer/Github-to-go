//
//  RPViewController.h
//  TableTest
//
//  Created by Robert Panzer on 01.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RPFlickViewController : UIViewController <UIGestureRecognizerDelegate>


-(id) init;

-(void)addChildViewController:(UIViewController *)childController title:(NSString*)aTitle;

@end
