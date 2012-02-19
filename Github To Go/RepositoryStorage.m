//
//  RepositoryStorage.m
//  Github To Go
//
//  Created by Robert Panzer on 19.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RepositoryStorage.h"

static RepositoryStorage* sharedStorage;

@interface RepositoryStorage() 

@property(strong) NSMutableDictionary* ownRepositories;
@property(strong) NSMutableDictionary* watchedRepositories;

@end

@implementation RepositoryStorage

@synthesize ownRepositories;
@synthesize watchedRepositories;

+(void)initialize {
    sharedStorage = [[RepositoryStorage alloc] init];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.ownRepositories = [NSMutableDictionary dictionary];
        self.watchedRepositories = [NSMutableDictionary dictionary];
    }
    return self;
}

+(RepositoryStorage *)sharedStorage {
    return sharedStorage;
}

-(void)addOwnRepository:(Repository*)repository {
    [ownRepositories setObject:repository forKey:repository.fullName];
}

-(void)addWatchedRepository:(Repository*)repository {
    [watchedRepositories setObject:repository forKey:repository.fullName];
}

-(BOOL)repositoryIsWatched:(Repository*)repository {
    BOOL ret = [watchedRepositories objectForKey:repository.fullName] != nil;
    return ret;
}

@end
