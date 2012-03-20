//
//  PullRequestCommentViewController.h
//  Github To Go
//
//  Created by Robert Panzer on 15.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullRequest.h"

@interface PullRequestCommentViewController : UITableViewController

@property (strong, nonatomic) PullRequest *pullRequest;
@property (strong, nonatomic) NSArray *comments;
@property (strong, nonatomic) IBOutlet UITableViewCell *addCommentCell;

-(id)initWithPullRequest:(PullRequest*)aPullRequest;
- (IBAction)showAddCommentDialog:(id)sender;

-(IBAction)loadComments;
@end

@interface PullRequestAddCommentViewController : UIViewController 
    
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UIView *waitScreen;
@property (strong, nonatomic) IBOutlet UINavigationItem *navigationItem;

@property (strong, nonatomic) PullRequest *pullRequest;
-(IBAction)sendComment:(id)sender;

-(IBAction)cancel:(id)sender;

- (id)initWithPullRequest:(PullRequest*)aPullRequest;
@end