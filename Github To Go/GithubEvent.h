//
//  GithubEvent.h
//  Github To Go
//
//  Created by Robert Panzer on 09.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"

@interface GithubEvent : NSObject {
    
}

@property(strong) NSString* text;
@property(strong) Person* person;
@property(strong) NSString* date;

-(id) initWithJSON:(NSDictionary*)jsonObject;


@end
