//
//  UITableViewCell+Commit.m
//  Github To Go
//
//  Created by Robert Panzer on 24.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UITableViewCell+Commit.h"

@implementation UITableViewCell (Commit)

static NSString *CommitCellIdentifier = @"CommitCell";
static NSInteger MESSAGE_TAG = 1;
static NSInteger AUTHOR_TAG = 2;
static NSInteger SHA_TAG = 3;
static NSInteger IMAGE_TAG = 4;
static NSInteger TIME_TAG = 5;

+(UITableViewCell *)createCommitCellForTableView:(UITableView *)tableView {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CommitCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CommitCellIdentifier];
        
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 55.0f, 55.0f)];
        imageView.tag = IMAGE_TAG;
        [cell.contentView addSubview:imageView];
        
        UILabel* messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(57.0f, 32.0f, tableView.frame.size.width - 57.0f, 38.0f)];
        messageLabel.font = [UIFont systemFontOfSize:13.0f];
        messageLabel.tag = MESSAGE_TAG;
        messageLabel.numberOfLines = 0;
        messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        messageLabel.textAlignment = NSTextAlignmentLeft;
        messageLabel.textColor = [UIColor blackColor];
        [cell.contentView addSubview:messageLabel];

        UILabel* timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(57.0f, 2.0f, 100.0f, 15.0f)];
        timeLabel.font = [UIFont systemFontOfSize:11.0f];
        timeLabel.tag = TIME_TAG;
        timeLabel.textAlignment = NSTextAlignmentLeft;
        timeLabel.textColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:timeLabel];

        UILabel* shaLabel = [[UILabel alloc] initWithFrame:CGRectMake(160.0f, 2.0f, tableView.frame.size.width - 162.0f, 15.0f)];
        shaLabel.font = [UIFont systemFontOfSize:11.0f];
        shaLabel.tag = SHA_TAG;
        shaLabel.textAlignment = NSTextAlignmentRight;
        shaLabel.textColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:shaLabel];
        
        UILabel* authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(57.0f, 20.0f, tableView.frame.size.width - 60.0f, 15.0f)];
        authorLabel.font = [UIFont systemFontOfSize:11.0f];
        authorLabel.tag = AUTHOR_TAG;
        authorLabel.textAlignment = NSTextAlignmentLeft;
        authorLabel.textColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:authorLabel];
        
    }
    return cell;
    
}

-(void)bindCommit:(Commit *)commit tableView:(UITableView *)tableView {
    UILabel *messageLabel = (UILabel*)[self.contentView viewWithTag:MESSAGE_TAG];
    UILabel *shaLabel = (UILabel*)[self.contentView viewWithTag:SHA_TAG];
    UILabel *authorLabel =  (UILabel*)[self.contentView viewWithTag:AUTHOR_TAG];
    UIImageView *imageView = (UIImageView*)[self.contentView viewWithTag:IMAGE_TAG];
    UILabel *timeLabel = (UILabel*)[self.contentView viewWithTag:TIME_TAG];

    imageView.image = nil;

    NSString *firstLine = [[commit.message componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] objectAtIndex:0];
    CGSize size = [firstLine sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(tableView.frame.size.width - 58.0f, 1000.0f) lineBreakMode:NSLineBreakByWordWrapping];

    messageLabel.frame = CGRectMake(57.0f, 32.0f, size.width, size.height);
    shaLabel.frame = CGRectMake(160.0f, 2.0f, tableView.frame.size.width - 162.0f, 15.0f);
    timeLabel.frame = CGRectMake(57.0f, 2.0f, 100.0f, 15.0f);
    authorLabel.frame = CGRectMake(57.0f, 17.0f, tableView.frame.size.width - 60.0f, 15.0f);
    
    
    messageLabel.text = firstLine;
    shaLabel.text = [commit.sha substringToIndex:10];
    authorLabel.text = [commit.author displayname];
    timeLabel.text = [NSDateFormatter localizedStringFromDate:commit.committedDate dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterMediumStyle];
    [commit.author loadImageIntoImageView:imageView];
}

+(CGFloat)tableView:(UITableView *)tableView heightForRowForCommit:(Commit *)commit {
    NSString *firstLine = [[commit.message componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] objectAtIndex:0];

    CGSize size = [firstLine sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(tableView.frame.size.width - 58.0f, 1000.0f) lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat height = size.height + 40;
    
    return height > 55.0f ? height : 55.0f;
    
}

@end
