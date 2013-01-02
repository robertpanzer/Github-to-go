//
//  RepositoryStorage.h
//  Github To Go
//
//  Created by Robert Panzer on 19.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Repository.h"

static NSString* LOADED_REPOS_NOTIFICATION = @"RPLoadedRepos";

@interface RepositoryStorage : NSObject

@property(strong, nonatomic) NSMutableDictionary* followedPersons;

@property(strong) NSMutableDictionary* ownRepositories;

@property(strong) NSMutableDictionary* watchedRepositories;

@property(strong) NSMutableDictionary* starredRepositories;

+(RepositoryStorage*)sharedStorage;

-(void)addOwnRepository:(Repository*)repository;

-(void)addWatchedRepository:(Repository*)repository;

-(void)addStarredRepository:(Repository*)repository;

-(void)removeWatchedRepository:(Repository*)repository;

-(void)removeStarredRepository:(Repository*)repository;

-(BOOL)repositoryIsStarred:(Repository*)repository;

-(BOOL)repositoryIsWatched:(Repository*)repository;

-(BOOL)repositoryIsOwned:(Repository*)repository;

-(void)loadFollowed;

-(void)loadOwnRepos;

-(void)loadFollowedRepos;

-(void)loadStarredRepos;

@end
