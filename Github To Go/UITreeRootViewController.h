//
//  UITreeRootViewController.h
//  Github To Go
//
//  Created by Robert Panzer on 30.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Repository.h"
#import "Commit.h"
#import "TreeViewController.h"
#import "BranchViewController.h"
#import "RPFlickViewController.h"

@interface UITreeRootViewController : RPFlickViewController

@property(strong,nonatomic) NSString* treeUrl;
@property(strong,nonatomic) NSString* absolutePath;
@property(strong,nonatomic) NSString* branchName;
@property(strong,nonatomic) Commit* commit;
@property(strong,nonatomic) Repository* repository;
@property(strong,nonatomic) TreeViewController* treeViewController;
@property(strong,nonatomic) BranchViewController* branchViewController;
@property(strong,nonatomic) NSString *htmlUrl;

-(id)initWithUrl:(NSString*)aTreeUrl absolutePath:(NSString*)anAbsolutePath commit:(Commit *)aCommit repository:(Repository *)aRepository branchName:(NSString*)aBranchName;

@end
