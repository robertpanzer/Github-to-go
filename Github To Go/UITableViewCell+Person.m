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

+(UITableViewCell *)createPersonCell:(NSString*)identifier tableView:(UITableView*)tableView {
    
    UITableViewCell* ret = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    
    UIImageView* imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(80.0f, 0.0f, tableView.rowHeight-2.0f, tableView.rowHeight-2.0f);
    imageView.tag = 4;
    [ret.contentView addSubview:imageView];

    UILabel* roleLabel = [[UILabel alloc] init];
    roleLabel.tag = 1;
    roleLabel.opaque = NO;
    roleLabel.backgroundColor = [UIColor clearColor];
    roleLabel.font = [UIFont systemFontOfSize:13.0f];
    [ret.contentView addSubview:roleLabel];
    
    UILabel* nameLabel = [[UILabel alloc] init];
    nameLabel.tag = 2;
    nameLabel.opaque = NO;
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    [ret.contentView addSubview:nameLabel];
    
    UILabel* emailLabel = [[UILabel alloc] init];
    emailLabel.tag = 3;
    emailLabel.opaque = NO;
    emailLabel.backgroundColor = [UIColor clearColor];
    emailLabel.font = [UIFont systemFontOfSize:13.0f];
    [ret.contentView addSubview:emailLabel];

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
    nameLabel.frame = CGRectMake(130.0f, 3.0f, tableView.frame.size.width - 160.0f, 15.0f);
    nameLabel.text = person.name;
    
    UILabel* emailLabel = (UILabel*)[self.contentView viewWithTag:3];
    emailLabel.frame = CGRectMake(130.0f, 23.0f, tableView.frame.size.width - 160.0f, 15.0f);
    emailLabel.text = person.email;
    

}

@end