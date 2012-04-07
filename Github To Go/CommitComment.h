//
//  CommitComment.h
//  Github To Go
//
//  Created by Robert Panzer on 06.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"

@interface CommitComment : NSObject

@property (strong, nonatomic) NSDate   *createdAt;
@property (strong, nonatomic) NSString *body;
@property (strong, nonatomic) NSNumber *identifier;
@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) Person   *user;
@property                     int       position;


- (id)initWithJSONObject:(NSDictionary*)jsonObject;

@end
