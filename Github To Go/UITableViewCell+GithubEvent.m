//
//  UITableViewCell+GithubEvent.m
//  Github To Go
//
//  Created by Robert Panzer on 03.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UITableViewCell+GithubEvent.h"
#import "QuartzCore/QuartzCore.h"

@implementation UITableViewCell (GithubEvent)

-(void)bindGithubEvent:(GithubEvent *)anEvent {
    
    UIImageView* imageView = (UIImageView*)[self.contentView viewWithTag:1];
    imageView.image = nil;
    
    UILabel* label = (UILabel*)[self.contentView viewWithTag:2];
    label.text = anEvent.text;
    [anEvent.person loadImageIntoImageView:imageView];
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

-(void)bindPushEvent:(PushEvent*)anEvent {
    [self bindGithubEvent:anEvent];
    if (anEvent.commits.count > 0) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
}

-(void)bindPullRequestEvent:(PullRequestEvent*)anEvent {
    [self bindGithubEvent:anEvent];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
}

-(void)bindCommitCommentEvent:(CommitCommentEvent*)anEvent {
    [self bindGithubEvent:anEvent];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
}

-(void)bindPullRequestReviewCommentEvent:(PullRequestReviewCommentEvent*)anEvent {
    [self bindGithubEvent:anEvent];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
}

@end
