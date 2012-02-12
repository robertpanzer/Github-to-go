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
    NSString* avatarUrl;
    
}

@property(strong) NSString* login;
@property(strong) NSString* name;
@property(strong) NSString* email;
@property(strong) NSString* avatarUrl;
@property(readonly) NSString* displayname;

-(id)initWithJSONObject:(NSDictionary*)dictionary;

-(id)initWithJSONObject:(NSDictionary*)dictionary JSONObject:(NSDictionary*)secondObject;

-(void)loadImageIntoImageView:(UIImageView*)imageView;
@end
