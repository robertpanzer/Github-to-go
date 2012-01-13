//
//  Branch.h
//  Github To Go
//
//  Created by Robert Panzer on 06.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Commit.h"
@interface Branch : NSObject {
    NSString* name;
    NSString* commitUrl;
    NSString* sha;
}

@property(strong) NSString* name;
@property(strong) NSString* commitUrl;
@property(strong) NSString* sha;

-(id)initWithJSONObject:(NSDictionary*)jsonObject;

@end
