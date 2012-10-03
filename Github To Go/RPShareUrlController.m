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

static NSString* sharePerTweetAction;
static NSString* sharePerMailAction;
static NSString* openInSafariAction;

static BOOL useActivityController = NO;

@interface RPShareUrlController() <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property(weak, nonatomic) UIViewController* viewController;

@property(strong, nonatomic) NSMutableArray* actions;
@property(strong, nonatomic) NSMutableArray* blocks;

@end



@class UIActivityViewController;

@implementation RPShareUrlController


+(void)initialize {
    if (NSClassFromString(@"UIActivityViewController") != NULL) {
        useActivityController = YES;
    }
    sharePerTweetAction = NSLocalizedString(@"Tweet", @"Tweet ActionSheet button");
    sharePerMailAction  = NSLocalizedString(@"Share via Mail", @"Mail ActionSheet button");
    openInSafariAction  = NSLocalizedString(@"Open in Safari", @"Open in Safari ActionSheet button");
}

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

-(void)addAction:(NSString*)anAction block:(void(^)())aBlock {
    [self.actions addObject:anAction];
    [self.blocks addObject:aBlock];
}

-(void)addActivity:(UIActivity*)activity {
    [self.actions addObject:activity];
}

-(void)showActionSheet:(id)sender {
    if (useActivityController) {
        NSMutableArray *newActions = [NSMutableArray arrayWithArray:self.actions];
        [newActions addObject:[[RPOpenInSafariActivity alloc] init]];
//        [self.actions addObject:[[RPOpenInSafariActivity alloc] init]];

        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[self.url]
                                                                                             applicationActivities:newActions];
        [self.viewController presentModalViewController:activityViewController animated:YES];
    } else {
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
        for (int i = 0; i < self.actions.count; i++) {
            if ([[self.actions objectAtIndex:i] isEqualToString:titleClicked]) {
                void (^block)() = [self.blocks objectAtIndex:i];
                block();
                
            }
        }
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissModalViewControllerAnimated:YES];
}


@end
