//
//  PullToRefreshTableViewControllerViewController.m
//  Github To Go
//
//  Created by Robert Panzer on 18.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PullToRefreshTableViewController.h"
#import <CoreText/CoreText.h>


@implementation ReloadLabel

@synthesize label, activityIndicator;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.height, 0.0f, frame.size.width - frame.size.height, frame.size.height)];
        self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.label.textAlignment = UITextAlignmentCenter;
        self.label.backgroundColor = [UIColor clearColor];
        self.label.opaque = NO;
        
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.activityIndicator.frame = CGRectMake(0.0f, 0.0f, frame.size.height, frame.size.height);
        self.activityIndicator.hidesWhenStopped = YES;
        self.activityIndicator.opaque = NO;
        
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.label];
        [self addSubview:self.activityIndicator];
    }
    return self;
}

-(NSString *)text {
    return label.text;
}

-(void)setText:(NSString *)text {
    label.text = text;
}

-(void)startActivity {
    [self.activityIndicator startAnimating];
    self.activityIndicator.hidden = NO;
}

-(void)stopActivity {
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden = YES;
}


@end




@interface PullToRefreshTableViewController ()

@property(nonatomic) BOOL useRefreshControl;
@end

@implementation PullToRefreshTableViewController

@synthesize reloadLabel;
@synthesize reloadPossible;
@synthesize isReloading;

@class UIRefreshControl;

-(void) viewDidLoad {
    [super viewDidLoad];
    Class refreshControlClass = NSClassFromString(@"UIRefreshControl");
    
    if (refreshControlClass != NULL) {
        self.useRefreshControl = YES;
        // New iOS 6 Refresh Control
        id refreshControl = [[refreshControlClass alloc] init];
        //TODO: Remove id cast once iOS6 is minimum requirement
        [self setRefreshControl:refreshControl];
        NSDictionary *dict =[NSDictionary dictionaryWithObjectsAndKeys:
                             [UIColor blackColor], kCTForegroundColorAttributeName,
                             nil];
        
        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@"Pull to refresh" attributes:dict];
        
        [refreshControl setAttributedTitle:title];
        [refreshControl addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];
    } else {
        self.reloadLabel = [[ReloadLabel alloc] initWithFrame:CGRectMake(0.0f, -40.0f, self.tableView.frame.size.width, 40.0f)];
        [self.tableView addSubview:self.reloadLabel];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    if (!self.useRefreshControl) {
        [self.tableView.panGestureRecognizer addTarget:self action:@selector(swiped:)];
    }

}

-(void)viewWillDisappear:(BOOL)animated {
    if (!self.useRefreshControl){
        [self.tableView.panGestureRecognizer removeTarget:self action:@selector(swiped:)];
    }
}

-(void) swiped:(UIPanGestureRecognizer*)recognizer {
    if (self.tableView.contentOffset.y < 0) {
        switch (recognizer.state) {
            case UIGestureRecognizerStateBegan:
                self.reloadPossible = NO; 
                break;
            case UIGestureRecognizerStateFailed:
            case UIGestureRecognizerStateCancelled:
                self.reloadPossible = NO; 
                break;
            case UIGestureRecognizerStateChanged:
            case UIGestureRecognizerStatePossible:
                if (self.tableView.contentOffset.y < -20.0f) {
                    self.reloadLabel.text = NSLocalizedString(@"Release to reload", @"Release to reload");
                    self.reloadPossible = YES; 
                } else if (self.tableView.contentOffset.y < 0.0f) {
                    self.reloadLabel.text = NSLocalizedString(@"Pull to reload", @"Pull to reload");
                    self.reloadPossible = NO;
                }
                break;
            case UIGestureRecognizerStateEnded:
                if (self.reloadPossible) {
                    if ([self respondsToSelector:@selector(reload)]) {
                        [self.tableView setContentOffset:CGPointMake(0.0f, -40.0f) animated:NO]; 
                        [self willReload];
                        [self reload];
                    }
                }
                break;
        }
    }
}

-(void)reload:(id)sender {
    [self reload];
}

-(void)reload {}

-(void)willReload {
    self.isReloading = YES;
    [self.reloadLabel startActivity];
}

-(void)reloadDidFinish {
    if (self.useRefreshControl) {
        [self.refreshControl endRefreshing];
    } else {
        if (self.isReloading) {
            [self.tableView setContentOffset:CGPointMake(0.0f, 0.0f) animated:YES];
        }
        self.isReloading = NO;
        [self.reloadLabel stopActivity];
    }
}

@end
