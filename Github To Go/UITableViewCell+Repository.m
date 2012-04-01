//
//  UITableViewCell+Repository.m
//  Github To Go
//
//  Created by Robert Panzer on 01.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UITableViewCell+Repository.h"

@implementation UITableViewCell (Repository)

+(UITableViewCell *)createRepositoryCellForTableView:(UITableView *)tableView {
    static NSString *CellIdentifier = @"RepositoryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.font = [UIFont systemFontOfSize:13.0f];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:11.0f];
    }
    return cell;
}


-(void)bindRepository:(Repository *)repository tableView:(UITableView *)tableView {
    self.textLabel.text = repository.fullName;
    self.detailTextLabel.text = repository.description;
}

@end
