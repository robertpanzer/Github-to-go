//
//  GithubEvent.h
//  Github To Go
//
//  Created by Robert Panzer on 09.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"
#import "CommitHistoryList.h"
#import "PullRequest.h"

@interface GithubEvent : NSObject 

@property(strong, nonatomic) NSString* text;
@property(strong, nonatomic) Person* person;
@property(strong, nonatomic) NSString* date;
@property(strong, nonatomic) Repository* repository;
@property(strong, nonatomic) NSString *primaryKey;


-(id) initWithJSON:(NSDictionary*)jsonObject;

@end

@interface PushEvent: GithubEvent

@property(strong) CommitHistoryList* commits;

-(id) initWithJSON:(NSDictionary *)jsonObject;

@end

@interface PullRequestEvent: GithubEvent 

@property (strong, nonatomic) PullRequest *pullRequest;

@end

@interface ForkEvent: GithubEvent 

@end


@interface CreateRepositoryEvent: GithubEvent 

@end

@interface EventFactory : NSObject 

+(GithubEvent*) createEventFromJsonObject:(NSDictionary*)jsonObject;

@end
