//
//  FileDiffViewController.h
//  Github To Go
//
//  Created by Robert Panzer on 14.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommitFile.h"

@interface FileDiffViewController : UIViewController {
    UILabel* label;
    UIScrollView* scrollView;
    CommitFile* commitFile;
}

@property(strong) IBOutlet UILabel* label;
@property(strong) IBOutlet UIScrollView* scrollView;
@property(strong) CommitFile* commitFile;

- (id)initWithCommitFile:(CommitFile*)aCommitFile;

- (IBAction)showFile:(id)sender;
@end
