//
//  Repository.h
//  TabBarTest
//
//  Created by Robert Panzer on 30.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"

@interface Repository : NSObject {
    NSString* name;
    NSString* description;
    NSString* masterBranch;
    Person* owner;
    NSDictionary* branches;
}

@property(strong) NSString* name;
@property(strong) NSString* description;
@property(strong) NSString* masterBranch;
@property(strong) Person* owner;
@property(strong) NSDictionary* branches;

-(id) initFromJSONObject:(NSDictionary*)json;

-(void)setBranchesFromJSONObject:(NSArray*)jsonArray ;

-(NSString*) urlOfMasterBranch;

@end
