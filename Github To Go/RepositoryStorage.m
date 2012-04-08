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

@synthesize ownRepositories;
@synthesize watchedRepositories;
@synthesize followedPersons;


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

@end
