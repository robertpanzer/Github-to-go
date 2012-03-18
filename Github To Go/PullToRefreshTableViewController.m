//
//  PullToRefreshTableViewControllerViewController.m
//  Github To Go
//
//  Created by Robert Panzer on 18.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PullToRefreshTableViewController.h"



@implementation ReloadLabel

@synthesize label;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
        self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.label.textAlignment = UITextAlignmentCenter;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.label];
    }
    return self;
}

-(NSString *)text {
    return label.text;
}

-(void)setText:(NSString *)text {
    label.text = text;
}

@end




@interface PullToRefreshTableViewController ()

@end

@implementation PullToRefreshTableViewController

@synthesize reloadLabel;
@synthesize reloadPossible;
@synthesize lastSwipeOffset;

-(void)viewWillAppear:(BOOL)animated {
    if (self.reloadLabel == nil) {
        self.reloadLabel = [[ReloadLabel alloc] initWithFrame:CGRectMake(0.0f, -40.0f, self.tableView.frame.size.width, 40.0f)];
        [self.tableView addSubview:self.reloadLabel];
    
        [self.tableView.panGestureRecognizer addTarget:self action:@selector(swiped:)];
    }

}

-(void) swiped:(UIPanGestureRecognizer*)recognizer {
    if (self.tableView.contentOffset.y < 0) {
        switch (recognizer.state) {
            case UIGestureRecognizerStateBegan:
                self.lastSwipeOffset = self.tableView.contentOffset.y;
                self.reloadPossible = NO; 
                break;
            case UIGestureRecognizerStateFailed:
            case UIGestureRecognizerStateCancelled:
                self.reloadPossible = NO; 
                break;
            case UIGestureRecognizerStateChanged:
            case UIGestureRecognizerStatePossible:
                if (self.lastSwipeOffset > self.tableView.contentOffset.y) {
                    self.reloadLabel.text = NSLocalizedString(@"Drop to reload", @"Drop to reload");
                    self.reloadPossible = YES; 
                } else if (self.lastSwipeOffset < self.tableView.contentOffset.y) {
                    self.reloadLabel.text = NSLocalizedString(@"Pull to reload", @"Pull to reload");
                    self.reloadPossible = NO;
                }
                self.lastSwipeOffset = self.tableView.contentOffset.y;
                break;
            case UIGestureRecognizerStateEnded:
                if (self.reloadPossible) {
                    if ([self respondsToSelector:@selector(reload)]) {
                        [self reload];
                    }
                }
                break;
        }
    }
}

-(void)reload {}

@end