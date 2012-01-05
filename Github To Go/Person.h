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
}

@property(strong) NSString* login;

-(id)initWithJSONObject:(NSDictionary*)dictionary;
@end
