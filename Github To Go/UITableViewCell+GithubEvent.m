//
//  UITableViewCell+GithubEvent.m
//  Github To Go
//
//  Created by Robert Panzer on 03.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UITableViewCell+GithubEvent.h"

@implementation UITableViewCell (GithubEvent)

-(void)bindGithubEvent:(GithubEvent *)anEvent {
    
    UIImageView* imageView = (UIImageView*)[self.contentView viewWithTag:1];
    UILabel* label = (UILabel*)[self.contentView viewWithTag:2];
    imageView.image = [UIImage imageNamed:@"gravatar-orgs.png"];
    label.text = anEvent.text;
    [anEvent.person loadImageIntoImageView:imageView];
    self.accessoryType = UITableViewCellAccessoryNone;
}

-(void)bindPushEvent:(PushEvent*)anEvent {
    [self bindGithubEvent:anEvent];
    if (anEvent.commits.count > 0) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
}

-(void)bindPullRequestEvent:(PullRequestEvent*)anEvent {
    [self bindGithubEvent:anEvent];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

@end
