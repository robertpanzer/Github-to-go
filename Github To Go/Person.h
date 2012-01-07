//
//  Person.h
//  Github To Go
//
//  Created by Robert Panzer on 04.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject {
    NSString* login;
    NSString* name;
    NSString* email;

}

@property(strong) NSString* login;
@property(strong) NSString* name;
@property(strong) NSString* email;

-(id)initWithJSONObject:(NSDictionary*)dictionary;
@end
