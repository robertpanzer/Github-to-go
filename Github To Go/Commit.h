//
//  Commit.h
//  Github To Go
//
//  Created by Robert Panzer on 04.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Person.h"
#import "Repository.h"

@interface Commit : NSObject {
    NSString* treeUrl;
    NSString* commitUrl;
    Person* author;
    Person* committer;
    NSString* message;
    NSArray* parentUrls;
    NSArray* parentCommitShas;
    NSArray* changedFiles;
    NSString* sha;
    int deletions;
    int additions;
    int total;
    NSString* committedDate;
    NSString* authoredDate;
    
    Repository* repository;
}

@property(strong) NSString* treeUrl;
@property(strong) NSString* commitUrl;
@property(strong) Person* author;
@property(strong) Person* committer;
@property(strong) NSString* message;
@property(strong) NSArray* parentUrls;
@property(strong) NSArray* parentCommitShas;
@property(strong) NSArray* changedFiles;
@property(strong) NSString* sha;

@property int deletions;
@property int additions;
@property int total;

@property(strong) NSString* committedDate;
@property(strong) NSString* authoredDate;

@property(strong) Repository* repository;

-(id)initWithJSONObjectFromPushEvent:(NSDictionary*)jsonObject committer:(Person*)aCommitter;

-(id)initMinimalDataWithJSONObject:(NSDictionary*)jsonObject repository:(Repository*)aRepository;

-(id)initWithJSONObject:(NSDictionary*)jsonObject repository:(Repository*)aRepository;



-(BOOL) matchesString:(NSString*)searchString;

- (void)loadObjectWithAbsolutePath:(NSString*)absolutePath;

@end
