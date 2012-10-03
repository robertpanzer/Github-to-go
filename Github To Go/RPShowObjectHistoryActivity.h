//
//  RPShowObjectHistoryActivity.h
//  Hub To Go
//
//  Created by Robert Panzer on 03.10.12.
//
//

#import <UIKit/UIKit.h>
#import "CommitFile.h"
#import "Repository.h"

@interface RPShowObjectHistoryActivity : UIActivity

@property(strong, nonatomic) NSString *commitSha;
@property(strong, nonatomic) Repository *repository;
@property(strong, nonatomic) NSString *absolutePath;
@property(strong, nonatomic) UIViewController *owningViewController;

- (id)initWithCommitSha:(NSString*)commitSha
             repository:(Repository*)repository
           absolutePath:(NSString*)absolutePath
   owningViewController:(UIViewController*)owningViewController;

@end
