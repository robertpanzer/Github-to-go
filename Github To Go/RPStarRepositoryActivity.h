//
//  RPStarRepositoryActivity.h
//  Hub To Go
//
//  Created by Robert Panzer on 02.01.13.
//
//

#import <UIKit/UIKit.h>
#import "Repository.h"

@interface RPStarRepositoryActivity : UIActivity

@property (strong, nonatomic) Repository* repository;

-(id) initWithRepository:(Repository*)repository;

@end
