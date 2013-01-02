//
//  Repository.h
//  TabBarTest
//
//  Created by Robert Panzer on 30.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"

@interface Repository : NSObject 

@property(strong, nonatomic) NSString *name;
@property(strong, nonatomic) NSString *description;
@property(strong, nonatomic) NSString *url;
@property(strong, nonatomic) NSString *htmlUrl;
@property(strong, nonatomic) NSNumber *repoId;
@property(strong, nonatomic) NSNumber *watchers;
@property BOOL private;
@property BOOL fork;
@property(strong, nonatomic) NSNumber *forks;
@property(strong, nonatomic) NSString *masterBranch;
@property(strong, nonatomic) Person *owner;
@property(strong, nonatomic) NSDictionary *branches;
@property(strong, nonatomic) NSDate *createdAt;
@property(strong, nonatomic) NSString *language;
@property(strong, nonatomic) NSNumber *openIssues;


@property(unsafe_unretained, readonly) NSString* fullName;

-(id) initFromJSONObject:(NSDictionary*)json;

-(void)setBranchesFromJSONObject:(NSArray*)jsonArray ;

-(NSString*) urlOfMasterBranch;

-(BOOL)matchesSearchString:(NSString*)searchString;

@end
