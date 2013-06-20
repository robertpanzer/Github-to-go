//
//  RepositoryStorage.m
//  Github To Go
//
//  Created by Robert Panzer on 19.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RepositoryStorage.h"
#import "Settings.h"
#import "NetworkProxy.h"

static RepositoryStorage* sharedStorage;

@interface RepositoryStorage() 


@end

@implementation RepositoryStorage

+(void)initialize {
    sharedStorage = [[RepositoryStorage alloc] init];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.ownRepositories = [NSMutableDictionary dictionary];
        self.watchedRepositories = [NSMutableDictionary dictionary];
        self.starredRepositories = [NSMutableDictionary dictionary];
        [self loadOwnRepos];
        [self loadFollowedRepos];
        [self loadStarredRepos];
    }
    return self;
}

+(RepositoryStorage *)sharedStorage {
    return sharedStorage;
}

-(void)addOwnRepository:(Repository*)repository {
    [self.ownRepositories setObject:repository forKey:repository.fullName];
}

-(void)addWatchedRepository:(Repository*)repository {
    [self.watchedRepositories setObject:repository forKey:repository.fullName];
    [[NSNotificationCenter defaultCenter] postNotificationName:LOADED_REPOS_NOTIFICATION object:self];
}

-(void)addStarredRepository:(Repository*)repository {
    [self.starredRepositories setObject:repository forKey:repository.fullName];
    [[NSNotificationCenter defaultCenter] postNotificationName:LOADED_REPOS_NOTIFICATION object:self];
}

-(void)removeWatchedRepository:(Repository*)repository {
    [self.watchedRepositories removeObjectForKey:repository.fullName];
    [[NSNotificationCenter defaultCenter] postNotificationName:LOADED_REPOS_NOTIFICATION object:self];
}

-(void)removeStarredRepository:(Repository*)repository {
    [self.starredRepositories removeObjectForKey:repository.fullName];
    [[NSNotificationCenter defaultCenter] postNotificationName:LOADED_REPOS_NOTIFICATION object:self];
}

-(BOOL)repositoryIsStarred:(Repository*)repository {
    BOOL ret = [self.starredRepositories objectForKey:repository.fullName] != nil;
    return ret;
}

-(BOOL)repositoryIsWatched:(Repository*)repository {
    BOOL ret = [self.watchedRepositories objectForKey:repository.fullName] != nil;
    return ret;
}

-(BOOL)repositoryIsOwned:(Repository*)repository {
    BOOL ret = [self.ownRepositories objectForKey:repository.fullName] != nil;
    return ret;
}

-(void)loadFollowed {
    if ([Settings sharedInstance].isUsernameSet) {
        [[NetworkProxy sharedInstance] loadStringFromURL:@"https://api.github.com/user/following" block:^(int statusCode, NSDictionary *aHeaderFields, id data) {
            if (statusCode == 200) {
                NSMutableDictionary *newFollowedPersons = [NSMutableDictionary dictionary];
                for (NSDictionary *jsonObject in data) {
                    Person *person = [[Person alloc] initWithJSONObject:jsonObject];
                    if (person.login) {
                        [newFollowedPersons setObject:person forKey:person.login];
                    }
                }
                self.followedPersons = newFollowedPersons;
            }
        } errorBlock:^(NSError * error) {
            // Simply ignore it.
        }];
    }
}

- (void)loadOwnRepos {
    if ([Settings sharedInstance].isUsernameSet) {
        [[NetworkProxy sharedInstance] loadStringFromURL:@"https://api.github.com/user/repos" block:^(int statusCode, NSDictionary* headerFields, id data) {
            NSMutableDictionary* newRepos = [NSMutableDictionary dictionary];
            for (NSDictionary* repoObject in data) {
                Repository *repo = [[Repository alloc] initFromJSONObject:repoObject];
                [[RepositoryStorage sharedStorage] addOwnRepository:repo];
                newRepos[repo.fullName] = repo;
            }
            self.ownRepositories = newRepos;
            [[NSNotificationCenter defaultCenter] postNotificationName:LOADED_REPOS_NOTIFICATION object:self];
        }];
    }
}

-(void)loadFollowedRepos {
    if ([Settings sharedInstance].isUsernameSet) {
        [[NetworkProxy sharedInstance] loadStringFromURL:@"https://api.github.com/user/subscriptions" block:^(int statusCode, NSDictionary* headerFields, id data) {
            NSMutableDictionary* newRepos = [NSMutableDictionary dictionary];
            
            for (NSDictionary* repoObject in data) {
                Repository* repo = [[Repository alloc] initFromJSONObject:repoObject];
                newRepos[repo.fullName] = repo;
            }
            self.watchedRepositories = newRepos;
            [[NSNotificationCenter defaultCenter] postNotificationName:LOADED_REPOS_NOTIFICATION object:self];
        }];
    }
}

-(void)loadStarredRepos {
    if ([Settings sharedInstance].isUsernameSet) {
        [[NetworkProxy sharedInstance] loadStringFromURL:@"https://api.github.com/user/starred" block:^(int statusCode, NSDictionary* headerFields, id data) {
            NSMutableDictionary* newRepos = [NSMutableDictionary dictionary];
            
            for (NSDictionary* repoObject in data) {
                Repository* repo = [[Repository alloc] initFromJSONObject:repoObject];
                if (! [[[Settings sharedInstance] username] isEqualToString: repo.owner.login]) {
                    newRepos[repo.fullName] = repo;
                }
            }
            self.starredRepositories = newRepos;
            [[NSNotificationCenter defaultCenter] postNotificationName:LOADED_REPOS_NOTIFICATION object:self];
        }];
    }
}


@end
