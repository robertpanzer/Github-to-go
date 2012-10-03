//
//  RPFollowPersonActivity.h
//  Hub To Go
//
//  Created by Robert Panzer on 30.09.12.
//
//

#import <UIKit/UIKit.h>

#import "Person.h"
@interface RPFollowPersonActivity : UIActivity

@property Person *person;

-(id)initWithPerson:(Person*)person;

@end
