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

static NSString* sharePerTweetAction;
static NSString* sharePerMailAction;
static NSString* openInSafariAction;

@interface RPShareUrlController() <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property(weak, nonatomic) UIViewController* viewController;

@property(strong, nonatomic) NSMutableArray* actions;
@property(strong, nonatomic) NSMutableArray* blocks;
@end

@implementation RPShareUrlController

@synthesize url;
@synthesize barButtonItem;
@synthesize viewController;
@synthesize title;
@synthesize actions, blocks;

+(void)initialize {
    sharePerTweetAction = NSLocalizedString(@"Tweet", @"Tweet ActionSheet button");
    sharePerMailAction  = NSLocalizedString(@"Share via Mail", @"Mail ActionSheet button");
    openInSafariAction  = NSLocalizedString(@"Open in Safari", @"Open in Safari ActionSheet button");
}

-(id) initWithUrl:(NSString*)anUrl title:(NSString*)aTitle viewController:(UIViewController*)aViewController {
    if (self = [super init]) {
        url = anUrl;
        title = aTitle;
        viewController = aViewController;
        actions = [NSMutableArray array];
        blocks = [NSMutableArray array];
        barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction 
                                                                      target:self 
                                                                      action:@selector(showActionSheet:)];
    }
    return self;
}

-(void)addAction:(NSString*)anAction block:(void(^)())aBlock {
    [actions addObject:anAction];
    [blocks addObject:aBlock];
}

-(void)showActionSheet:(id)sender {
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
                                                             delegate:self 
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel Button") 
                                               destructiveButtonTitle:nil otherButtonTitles:nil];
    
    if ([TWTweetComposeViewController canSendTweet]) {
        [actionSheet addButtonWithTitle:sharePerTweetAction];
    }
    
    if ([MFMailComposeViewController canSendMail]) {
        [actionSheet addButtonWithTitle:sharePerMailAction];
    }
    [actionSheet addButtonWithTitle:openInSafariAction];
    
    for (NSString* action in self.actions) {
        [actionSheet addButtonWithTitle:action];
    }
    
    [actionSheet showFromBarButtonItem:self.barButtonItem animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString* titleClicked = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([sharePerTweetAction isEqualToString:titleClicked]) {
        TWTweetComposeViewController *tweetController = [[TWTweetComposeViewController alloc] init];
        [tweetController addURL:[NSURL URLWithString:self.url]];
        if (self.title.length > 100) {
            [tweetController setInitialText:[self.title substringToIndex:100]];
        } else {
            [tweetController setInitialText:self.title];
        }
        [self.viewController presentModalViewController:tweetController animated:YES];
    } else if ([sharePerMailAction isEqualToString:titleClicked]) {
        MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
        [mailController setMessageBody:self.url isHTML:NO];
        mailController.mailComposeDelegate = self;
        [mailController setSubject:self.title];
        [self.viewController presentModalViewController:mailController animated:YES];
    } else if ([openInSafariAction isEqualToString:titleClicked]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.url]];
    } else {
        for (int i = 0; i < actions.count; i++) {
            if ([[actions objectAtIndex:i] isEqualToString:titleClicked]) {
                void (^block)() = [blocks objectAtIndex:i];
                block();
                
            }
        }
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissModalViewControllerAnimated:YES];
}


@end
