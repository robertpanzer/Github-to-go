//
//  RepositoryStorage.h
//  Github To Go
//
//  Created by Robert Panzer on 19.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Repository.h"

@interface RepositoryStorage : NSObject

@property(strong, nonatomic) NSMutableDictionary* followedPersons;

+(RepositoryStorage*)sharedStorage;

-(void)addOwnRepository:(Repository*)repository;

-(void)addWatchedRepository:(Repository*)repository;

-(BOOL)repositoryIsWatched:(Repository*)repository;

-(void)loadFollowed;

@end
