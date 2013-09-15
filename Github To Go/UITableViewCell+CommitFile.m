//
//  UITableViewCell+CommitFile.m
//  Github To Go
//
//  Created by Robert Panzer on 11.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UITableViewCell+CommitFile.h"
#import "QuartzCore/QuartzCore.h"

static UIColor *addColor;
static UIColor *deleteColor;
static UIImage *commentsImage;

@implementation UITableViewCell (CommitFile)

+(UITableViewCell *)createCommitFileCellForTableView:(UITableView *)tableView {
    if (addColor == nil) {
        addColor = [UIColor colorWithRed:0.33f green:0.8f blue:0.33f alpha:1.0f];
    }
    if (deleteColor == nil) {
        deleteColor = [UIColor colorWithRed:0.8f green:0.33f blue:0.33f alpha:1.0f];
    }
    static NSString *CommitFileCellIdentifier = @"CommitFileCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CommitFileCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CommitFileCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
        nameLabel.font =  [UIFont systemFontOfSize:13.0f];
        nameLabel.numberOfLines = 0;
        nameLabel.font =  [UIFont systemFontOfSize:13.0f];
        nameLabel.tag = 41;
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.opaque = NO;
        [cell addSubview:nameLabel];

        
        UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0.0f, 10.0f, 10.0f)];
        statusLabel.backgroundColor = [UIColor darkGrayColor];
        statusLabel.textColor = [UIColor lightTextColor];
        statusLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        statusLabel.textAlignment = NSTextAlignmentCenter;
        statusLabel.tag = 42;
        statusLabel.layer.cornerRadius = 5;
        statusLabel.opaque = NO;
        [cell addSubview:statusLabel];

        if (commentsImage == nil) {
            commentsImage = [UIImage imageNamed:@"Comment"];
        }

        UIImageView *commentsImageView = [[UIImageView alloc] initWithImage:commentsImage];
        commentsImageView.hidden = YES;
        commentsImageView.opaque = NO;
        commentsImageView.tag = 44;
        [cell addSubview:commentsImageView];
        
//        UILabel *commentsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0.0f, 10.0f, 10.0f)];
//        commentsLabel.backgroundColor = [UIColor darkGrayColor];
//        commentsLabel.textColor = [UIColor lightTextColor];
//        commentsLabel.font = [UIFont boldSystemFontOfSize:13.0f];
//        commentsLabel.textAlignment = UITextAlignmentCenter;
//        commentsLabel.tag = 43;
//        commentsLabel.layer.cornerRadius = 5;
//        commentsLabel.opaque = NO;
//        commentsLabel.text = @"c";
//        [cell addSubview:commentsLabel];

    }
    return cell;
}

-(void)bindCommitFile:(CommitFile *)commitFile tableView:(UITableView*)tableView {
    UILabel *statusLabel = (UILabel*)[self viewWithTag:42];
    statusLabel.frame = CGRectMake(17.0f, 13.0f, 18.0f, 18.0f);
    if ([commitFile.status isEqualToString:@"added"]) {
        statusLabel.text = @"A";
        statusLabel.backgroundColor = addColor;
    } else if ([commitFile.status isEqualToString:@"removed"]) {
        statusLabel.text = @"D";
        statusLabel.backgroundColor = deleteColor;
    } else {
        statusLabel.text = @"M";
        statusLabel.backgroundColor = [UIColor darkGrayColor];
    }
    
    UILabel *nameLabel = (UILabel*)[self viewWithTag:41];
    nameLabel.text = commitFile.fileName;

    CGSize size = [commitFile.fileName sizeWithFont:[UIFont systemFontOfSize:13.0f]
                                  constrainedToSize:CGSizeMake(self.frame.size.width - 70.0f, 1000.0f)
                                      lineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat height = tableView.rowHeight;
    if (size.height > tableView.rowHeight) {
        height = size.height;
    }
    
    nameLabel.frame = CGRectMake(40.0f, 0.0f, self.frame.size.width - 70, height);
    
    UILabel *commentsLabel = (UILabel*)[self viewWithTag:43];
    commentsLabel.hidden = YES;
    
}

-(void)bindCommitFile:(CommitFile *)commitFile comments:(NSArray*)comments tableView:(UITableView*)tableView {
    UILabel *statusLabel = (UILabel*)[self viewWithTag:42];
    statusLabel.frame = CGRectMake(17.0f, 13.0f, 18.0f, 18.0f);
    if ([commitFile.status isEqualToString:@"added"]) {
        statusLabel.text = @"A";
        statusLabel.backgroundColor = addColor;
    } else if ([commitFile.status isEqualToString:@"removed"]) {
        statusLabel.text = @"D";
        statusLabel.backgroundColor = deleteColor;
    } else {
        statusLabel.text = @"M";
        statusLabel.backgroundColor = [UIColor darkGrayColor];
    }
    
    UILabel *nameLabel = (UILabel*)[self viewWithTag:41];
    nameLabel.text = commitFile.fileName;
    
    CGFloat width = 0.0;
    if (comments.count == 0) {
        width = tableView.frame.size.width - 70.0f;
    } else {
        width = tableView.frame.size.width - 105.0f;
    }

    CGSize size = [commitFile.fileName sizeWithFont:[UIFont systemFontOfSize:13.0f]
                                  constrainedToSize:CGSizeMake(width, 1000.0f)
                                      lineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat height = tableView.rowHeight;
    if (size.height > tableView.rowHeight) {
        height = size.height;
    }
    
    nameLabel.frame = CGRectMake(40.0f, 0.0f, width, height);
    
//    UILabel *commentsLabel = (UILabel*)[self viewWithTag:43];
//    
//    commentsLabel.hidden = comments.count == 0;
//    commentsLabel.frame = CGRectMake(self.frame.size.width - 30.0f, 10.0f, 18.0f, 18.0f);

    UIView *commentsImageView = [self viewWithTag:44];
    commentsImageView.hidden = comments.count == 0;
    commentsImageView.frame = CGRectMake(self.frame.size.width - 65.0f, 10.0f, 32.0f, 32.0f);
    
}


+(CGFloat)tableView:(UITableView *)tableView heightForRowForCommitFile:(CommitFile *)commitFile comments:(NSArray*)comments {
    
    CGFloat width = 0.0;
    if (comments.count == 0) {
        width = tableView.frame.size.width - 70.0f;
    } else {
        width = tableView.frame.size.width - 105.0f;
    }
    
    CGSize size = [commitFile.fileName sizeWithFont:[UIFont systemFontOfSize:13.0f]
                                  constrainedToSize:CGSizeMake(width, 1000.0f)
                                      lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat height = size.height + 6;
    
    return height > tableView.rowHeight ? height : tableView.rowHeight;
   
}


@end
