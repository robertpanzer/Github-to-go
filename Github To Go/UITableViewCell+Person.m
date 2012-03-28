//
//  UITableViewCell+Person.m
//  Github To Go
//
//  Created by Robert Panzer on 04.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UITableViewCell+Person.h"
#import "NetworkProxy.h"
#import "QuartzCore/QuartzCore.h"

@implementation UITableViewCell (Person)

+(UITableViewCell *)createPersonCellForTableView:(UITableView*)tableView {
    
    UITableViewCell* ret = [tableView dequeueReusableCellWithIdentifier:@"PersonCell"];
    if (ret == nil) {
    
        ret = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PersonCell"];
        
        ret.selectionStyle= UITableViewCellSelectionStyleNone;
        
        UIImageView* imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(80.0f, 0.0f, tableView.rowHeight-2.0f, tableView.rowHeight-2.0f);
        imageView.tag = 4;
        imageView.layer.cornerRadius = 10.0f;
        imageView.layer.masksToBounds = YES;
        [ret.contentView addSubview:imageView];
        
        UILabel* roleLabel = [[UILabel alloc] init];
        roleLabel.tag = 1;
        roleLabel.opaque = NO;
        roleLabel.backgroundColor = [UIColor clearColor];
        roleLabel.font = [UIFont systemFontOfSize:13.0f];
        [ret.contentView addSubview:roleLabel];
        
        ret.textLabel.font = [UIFont systemFontOfSize:13.0f];
        
        
        UILabel* nameLabel = [[UILabel alloc] init];
        nameLabel.tag = 2;
        nameLabel.opaque = NO;
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        nameLabel.textColor = [UIColor colorWithRed:0.22f green:0.33f blue:0.53f alpha:1.0f];
        nameLabel.textAlignment = UITextAlignmentRight;
        [ret.contentView addSubview:nameLabel];
        
        UILabel* emailLabel = [[UILabel alloc] init];
        emailLabel.tag = 3;
        emailLabel.opaque = NO;
        emailLabel.backgroundColor = [UIColor clearColor];
        emailLabel.font = [UIFont systemFontOfSize:13.0f];
        emailLabel.textColor = [UIColor colorWithRed:0.22f green:0.33f blue:0.53f alpha:1.0f];
        emailLabel.textAlignment = UITextAlignmentRight;
        [ret.contentView addSubview:emailLabel];
    }
    return ret;
}

-(void)bindPerson:(Person *)person role:(NSString*)role tableView:(UITableView*)tableView {
    
    UIImageView* imageView = (UIImageView*)[self.contentView viewWithTag:4];
    imageView.image = [UIImage imageNamed:@"gravatar-orgs.png"];
    [person loadImageIntoImageView:imageView];

    UILabel* rolelabel = (UILabel*)[self.contentView viewWithTag:1];
    rolelabel.frame = CGRectMake(10.0f, 14.0f, 68.0f, 14.0f);
    rolelabel.text = role;

    UILabel* nameLabel = (UILabel*)[self.contentView viewWithTag:2];
    if (person.name != nil) {
        nameLabel.text = person.name;
    } else {
        nameLabel.text = person.login;
    }
    
    UILabel* emailLabel = (UILabel*)[self.contentView viewWithTag:3];
    if (person.email == nil) {
        nameLabel.frame = CGRectMake(130.0f, 14.0f, tableView.frame.size.width - 180.0f, 14.0f);
        emailLabel.hidden = YES;
    } else {
        nameLabel.frame = CGRectMake(130.0f, 3.0f, tableView.frame.size.width - 180.0f, 15.0f);
        emailLabel.hidden = NO;
        emailLabel.frame = CGRectMake(130.0f, 23.0f, tableView.frame.size.width - 180.0f, 15.0f);
        emailLabel.text = person.email;
    }    
    if (person.login != nil) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
}

+(UITableViewCell*)createSimplePersonCellForTableView:(UITableView*)tableView {
    UITableViewCell* ret = [tableView dequeueReusableCellWithIdentifier:@"PersonCell"];
    if (ret == nil) {
        ret = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PersonCell"];
        
        UIImageView* imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(0.0f, 0.0f, tableView.rowHeight-2.0f, tableView.rowHeight-2.0f);
        imageView.tag = 4;
        imageView.layer.cornerRadius = 10.0f;
        imageView.layer.masksToBounds = YES;
        [ret.contentView addSubview:imageView];

        UILabel* nameLabel = [[UILabel alloc] init];
        nameLabel.tag = 2;
        nameLabel.opaque = NO;
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        nameLabel.textColor = [UIColor colorWithRed:0.22f green:0.33f blue:0.53f alpha:1.0f];
        nameLabel.textAlignment = UITextAlignmentLeft;
        nameLabel.frame = CGRectMake(tableView.rowHeight, 0.0f, tableView.frame.size.width - tableView.rowHeight, tableView.rowHeight);

        [ret.contentView addSubview:nameLabel];

    }
    return ret;
}

-(void)bindPerson:(Person *)person tableView:(UITableView*)tableView {
    UIImageView* imageView = (UIImageView*)[self.contentView viewWithTag:4];
    imageView.image = [UIImage imageNamed:@"gravatar-orgs.png"];
    [person loadImageIntoImageView:imageView];
    
    UILabel* nameLabel = (UILabel*)[self.contentView viewWithTag:2];
    nameLabel.text = person.displayname;
}



@end
