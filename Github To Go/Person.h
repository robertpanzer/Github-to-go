//
//  Person.h
//  Github To Go
//
//  Created by Robert Panzer on 04.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject /*{
    NSString* login;
    NSString* name;
    NSString* email;
    NSString* avatarUrl;
    
}*/

@property(strong, nonatomic) NSString* login;
@property(strong, nonatomic) NSString* name;
@property(strong, nonatomic) NSString* email;
@property(strong, nonatomic) NSString* avatarUrl;
@property(unsafe_unretained, readonly) NSString* displayname;

@property(strong, nonatomic) NSNumber *publicRepos;
@property(strong, nonatomic) NSString *repos;
@property(strong, nonatomic) NSString *blog;
@property(strong, nonatomic) NSString *location;
@property(strong, nonatomic) NSNumber *publicGists;
@property(strong, nonatomic) NSDate *createdAt;
@property(nonatomic) BOOL hireable;
@property(strong, nonatomic) NSNumber *following;
@property(strong, nonatomic) NSNumber *followers;
@property(strong, nonatomic) NSString *bio;
@property(strong, nonatomic) NSString *url;
@property(strong, nonatomic) NSString *avatarId;

-(id)initWithJSONObject:(NSDictionary*)dictionary;

-(id)initWithJSONObject:(NSDictionary*)dictionary JSONObject:(NSDictionary*)secondObject;

-(id)initWithLogin:(NSString*)aLogin;

-(void)loadImageIntoImageView:(UIImageView*)imageView;

+(void)clearCache;
@end
