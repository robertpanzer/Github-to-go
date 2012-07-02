//
//  Issue.h
//  Hub To Go
//
//  Created by Robert Panzer on 22.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"
#import "Repository.h"

@interface Issue : NSObject

@property(strong) NSDate* createdAt;
@property(strong) NSDate* updatedAt;
@property(strong) NSDate* closedAt;
@property(strong) NSString* state;
@property(strong) Person* creator;
@property(strong) NSString* title;
@property(strong) NSString* body;
@property(strong) NSNumber* number;
@property(strong) NSString *htmlUrl;

@property(strong, nonatomic) Repository *repository;

-(id)initWithJSONObject:(NSDictionary*)jsonObject repository:(Repository*)aRepository;


@end
