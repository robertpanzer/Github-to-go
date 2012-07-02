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

@interface RPShareUrlController() <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property(weak, nonatomic) UIViewController* viewController;

@end

@implementation RPShareUrlController

@synthesize url;
@synthesize barButtonItem;
@synthesize viewController;
@synthesize title;

+(void)initialize {
    sharePerTweetAction = NSLocalizedString(@"Tweet", @"Tweet ActionSheet button");
    sharePerMailAction  = NSLocalizedString(@"Share via Mail", @"Mail ActionSheet button");
}

-(id) initWithUrl:(NSString*)anUrl title:(NSString*)aTitle viewController:(UIViewController*)aViewController {
    if (self = [super init]) {
        url = anUrl;
        title = aTitle;
        viewController = aViewController;
        barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActionSheet:)];
    }
    return self;
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
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissModalViewControllerAnimated:YES];
}


@end
