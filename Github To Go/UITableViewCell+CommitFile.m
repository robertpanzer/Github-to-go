//
//  UITableViewCell+CommitFile.m
//  Github To Go
//
//  Created by Robert Panzer on 11.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UITableViewCell+CommitFile.h"


@implementation UITableViewCell (CommitFile)


+(UITableViewCell *)createCommitFileCellForTableView:(UITableView *)tableView {
    static NSString *CommitFileCellIdentifier = @"CommitFileCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CommitFileCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CommitFileCellIdentifier];
        cell.selectionStyle= UITableViewCellSelectionStyleNone;
        cell.textLabel.font =  [UIFont systemFontOfSize:13.0f];;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.numberOfLines = 0;
    }
    return cell;
}

-(void)bindCommitFile:(CommitFile *)commitFile {
    self.textLabel.text = commitFile.fileName;
    self.detailTextLabel.text = nil;
}

+(CGFloat)tableView:(UITableView *)tableView heightForRowForCommitFile:(CommitFile *)commitFile {
    CGSize size = [commitFile.fileName sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(tableView.frame.size.width - 60.0f/*280.0f*/, 1000.0f) lineBreakMode:UILineBreakModeWordWrap];
    CGFloat height = size.height + 10;
    
    return height > tableView.rowHeight ? height : tableView.rowHeight;
   
}
@end
