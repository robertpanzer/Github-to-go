//
//  PullRequestCommentViewController.h
//  Github To Go
//
//  Created by Robert Panzer on 15.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullRequest.h"
#import "Issue.h"

@interface PullRequestCommentViewController : UITableViewController

@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSNumber *number;
@property (strong, nonatomic) NSArray *comments;
@property (strong, nonatomic) IBOutlet UITableViewCell *addCommentCell;

- (id)initWithUrl:(NSString*)anUrl number:(NSNumber*)aNumber;

- (IBAction)showAddCommentDialog:(id)sender;

-(IBAction)loadComments;
@end

@interface PullRequestAddCommentViewController : UIViewController 
    
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UIView *waitScreen;
@property (strong, nonatomic) IBOutlet UINavigationItem *navigationItem;

@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSNumber *number;

-(IBAction)sendComment:(id)sender;

-(IBAction)cancel:(id)sender;

- (id)initWithUrl:(NSString*)anUrl number:(NSNumber*)aNumber;

@end