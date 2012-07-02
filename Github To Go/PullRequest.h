//
//  PullRequest.h
//  Github To Go
//
//  Created by Robert Panzer on 09.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"
#import "Repository.h"

@interface PullRequest : NSObject

@property(strong) NSDate* createdAt;
@property(strong) NSDate* updatedAt;
@property(strong) NSString* state;
@property(strong) Person* creator;
@property(strong) NSString* title;
@property(strong) NSString* body;
@property(strong) NSNumber* number;
@property(strong, nonatomic) NSString* selfUrl;
@property(strong, nonatomic) NSString* htmlUrl;
@property(strong, nonatomic) NSString *issueCommentsUrl, *reviewCommentsUrl;
@property(nonatomic) BOOL merged;
@property(strong, nonatomic) Repository *repository;

- (id)initWithJSONObject:(NSDictionary*)jsonObject repository:(Repository*)aRepository;

@end

@interface PullRequestIssueComment : NSObject

@property(strong, nonatomic) NSString* body;
@property(strong, nonatomic) NSDate *createdAt;
@property(strong, nonatomic) Person* user;

- (id)initWithJSONObject:(NSDictionary*)jsonObject;

@end

