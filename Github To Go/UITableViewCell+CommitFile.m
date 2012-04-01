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
        statusLabel.textAlignment = UITextAlignmentCenter;
        statusLabel.tag = 42;
        statusLabel.layer.cornerRadius = 5;
        statusLabel.opaque = NO;
        [cell addSubview:statusLabel];
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

    CGSize size = [commitFile.fileName sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(self.frame.size.width - 70.0f, 1000.0f) lineBreakMode:UILineBreakModeWordWrap];
    
    CGFloat height = tableView.rowHeight;
    if (size.height > tableView.rowHeight) {
        height = size.height;
    }
    
    nameLabel.frame = CGRectMake(40.0f, 0.0f, self.frame.size.width - 70, height);
    
}

+(CGFloat)tableView:(UITableView *)tableView heightForRowForCommitFile:(CommitFile *)commitFile {
    CGSize size = [commitFile.fileName sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(tableView.frame.size.width - 70.0f, 1000.0f) lineBreakMode:UILineBreakModeWordWrap];
    CGFloat height = size.height + 6;
    
    return height > tableView.rowHeight ? height : tableView.rowHeight;
   
}
@end
