//
//  RPShareUrlController.m
//  Hub To Go
//
//  Created by Robert Panzer on 01.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RPShareUrlController.h"

#import <Twitter/Twitter.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "RPOpenInSafariActivity.h"

@interface RPShareUrlController() <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property(weak, nonatomic) UIViewController* viewController;

@property(strong, nonatomic) NSMutableArray* actions;
@property(strong, nonatomic) NSMutableArray* blocks;

@end



@class UIActivityViewController;

@implementation RPShareUrlController

-(id) initWithUrl:(NSString*)anUrl title:(NSString*)aTitle viewController:(UIViewController*)aViewController {
    if (self = [super init]) {
        _url = anUrl;
        _title = aTitle;
        _viewController = aViewController;
        _actions = [NSMutableArray array];
        _blocks = [NSMutableArray array];
        _barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                       target:self
                                                                       action:@selector(showActionSheet:)];
    }
    return self;
}

-(void)addActivity:(UIActivity*)activity {
    [self.actions addObject:activity];
}

-(void)showActionSheet:(id)sender {
    NSMutableArray *newActions = [NSMutableArray arrayWithArray:self.actions];
    [newActions addObject:[[RPOpenInSafariActivity alloc] init]];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[self.url]
                                                                                         applicationActivities:newActions];
    [self.viewController presentViewController:activityViewController animated:YES completion:nil];
}



@end
