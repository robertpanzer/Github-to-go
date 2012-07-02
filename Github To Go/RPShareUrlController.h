//
//  RPShareUrlController.h
//  Hub To Go
//
//  Created by Robert Panzer on 01.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RPShareUrlController : NSObject

@property(strong, nonatomic) NSString* url;
@property(strong, nonatomic) NSString* title;
@property(strong, readonly, nonatomic) UIBarButtonItem *barButtonItem;

-(id) initWithUrl:(NSString*)anUrl title:(NSString*)aTitle viewController:(UIViewController*)aViewController;

@end
