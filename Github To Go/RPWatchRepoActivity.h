//
//  RPWatchRepoActivity.h
//  Hub To Go
//
//  Created by Robert Panzer on 14.10.12.
//
//

#import <UIKit/UIKit.h>
#import "Repository.h"

@interface RPWatchRepoActivity : UIActivity

@property (strong, nonatomic) Repository* repository;

-(id) initWithRepository:(Repository*)repository;

@end
