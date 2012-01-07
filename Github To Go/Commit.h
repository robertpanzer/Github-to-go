//
//  Commit.h
//  Github To Go
//
//  Created by Robert Panzer on 04.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Person.h"

@interface Commit : NSObject {
    NSString* treeUrl;
    Person* author;
    Person* committer;
    NSString* message;
    NSArray* parentUrls;
    
}

@property(strong) NSString* treeUrl;
@property(strong) Person* author;
@property(strong) Person* committer;
@property(strong) NSString* message;
@property(strong) NSArray* parentUrls;

-(id)initWithJSONObject:(NSDictionary*)jsonObject;
@end
