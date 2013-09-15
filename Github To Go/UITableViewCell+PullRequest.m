//
//  UITableViewCell+PullRequest.m
//  Github To Go
//
//  Created by Robert Panzer on 11.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UITableViewCell+PullRequest.h"
#import "QuartzCore/QuartzCore.h"
#import "PullRequest.h"

@implementation UITableViewCell (PullRequest)


+(UITableViewCell *)createPullRequestIssueCommentCellForTableView:(UITableView*)tableView {
    
    UITableViewCell* ret = [tableView dequeueReusableCellWithIdentifier:@"PullRequestIssueComment"];
    if (ret == nil) {
        
        ret = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PullRequestIssueComment"];
        
        UIImageView* imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(0.0f, 0.0f, tableView.rowHeight-2.0f, tableView.rowHeight-2.0f);
        imageView.tag = 1;
        [ret.contentView addSubview:imageView];
        
        UILabel* nameLabel = [[UILabel alloc] init];
        nameLabel.tag = 2;
        nameLabel.opaque = NO;
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        nameLabel.textColor = [UIColor colorWithRed:0.22f green:0.33f blue:0.53f alpha:1.0f];
        nameLabel.textAlignment = NSTextAlignmentRight;
        [ret.contentView addSubview:nameLabel];
        
        UILabel* bodyLabel = [[UILabel alloc] init];
        bodyLabel.tag = 3;
        bodyLabel.opaque = NO;
        bodyLabel.backgroundColor = [UIColor clearColor];
        bodyLabel.font = [UIFont systemFontOfSize:13.0f];
        bodyLabel.textColor = [UIColor blackColor];
        bodyLabel.textAlignment = NSTextAlignmentLeft;
        bodyLabel.numberOfLines = 0;
        bodyLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [ret.contentView addSubview:bodyLabel];

        UILabel* dateLabel = [[UILabel alloc] init];
        dateLabel.tag = 4;
        dateLabel.opaque = NO;
        dateLabel.backgroundColor = [UIColor clearColor];
        dateLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        dateLabel.textColor = [UIColor colorWithRed:0.22f green:0.33f blue:0.53f alpha:1.0f];
        dateLabel.textAlignment = NSTextAlignmentLeft;
        [ret.contentView addSubview:dateLabel];
    }
    return ret;
}

-(void)bindPullRequestIssueComment:(PullRequestIssueComment*)issueComment tableView:(UITableView*)tableView {
    
    UIImageView* imageView = (UIImageView*)[self.contentView viewWithTag:1];
    imageView.layer.cornerRadius = 10.0f;
    imageView.layer.masksToBounds = YES;
    imageView.image = nil;
    [issueComment.user loadImageIntoImageView:imageView];
    
    UILabel* namelabel = (UILabel*)[self.contentView viewWithTag:2];
    namelabel.frame = CGRectMake(imageView.frame.size.width, 17.0f, tableView.frame.size.width - imageView.frame.size.width - 40.0f, 14.0f);
    namelabel.text = issueComment.user.displayname;

    UILabel* datelabel = (UILabel*)[self.contentView viewWithTag:4];
    datelabel.frame = CGRectMake(imageView.frame.size.width, 0.0f, tableView.frame.size.width - imageView.frame.size.width - 40.0f, 14.0f);
    NSString *s = [NSDateFormatter localizedStringFromDate:issueComment.createdAt dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle];
    datelabel.text = s;

    UILabel* bodyLabel = (UILabel*)[self.contentView viewWithTag:3];
    bodyLabel.text = issueComment.body;
    CGFloat textHeight = [issueComment.body sizeWithFont:[UIFont systemFontOfSize:13.0f]
                                       constrainedToSize:CGSizeMake(tableView.frame.size.width - 40.0f, 2000.0f)
                                           lineBreakMode:NSLineBreakByWordWrapping].height;
    bodyLabel.frame = CGRectMake(2.0f, imageView.frame.size.height, tableView.frame.size.width - 40.0f, textHeight);
}

+(CGFloat)tableView:(UITableView *)tableView heightForRowForIssueComment:(PullRequestIssueComment*)issueComment {
    CGSize size = [issueComment.body sizeWithFont:[UIFont systemFontOfSize:13.0f]
                                constrainedToSize:CGSizeMake(tableView.frame.size.width - 40.0f, 2000.0f)
                                    lineBreakMode:NSLineBreakByWordWrapping];
    
    return 60.0f + size.height;
    
}

@end
