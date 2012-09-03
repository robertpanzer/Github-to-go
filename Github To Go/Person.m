//
//  Person.m
//  Github To Go
//
//  Created by Robert Panzer on 04.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Person.h"
#import "NetworkProxy.h"
#import "NSString+ISO8601Parsing.h"
#import "QuartzCore/QuartzCore.h"

#import "NSDictionary+RPJSONObjectAccess.h"

static NSCache* url2Image;

static NSMutableDictionary* image2SequenceNumber;

static long sequenceCounter = 0;

@implementation Person 

@synthesize login;
@synthesize name;
@synthesize email;
@synthesize avatarUrl;

@synthesize publicGists;
@synthesize publicRepos;
@synthesize bio;
@synthesize repos;
@synthesize createdAt, followers, following, hireable, location, blog, url, username;
@synthesize avatarId;

+ (void)initialize {
    url2Image = [[NSCache alloc] init];
    image2SequenceNumber = [[NSMutableDictionary alloc] init];
}


- (id)initWithJSONObject:(NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        if (dictionary != nil && ![dictionary isEqual:[NSNull null]]) {
            self.login = [dictionary jsonObjectForKey:@"login"];
            self.name = [dictionary jsonObjectForKey:@"name"];
            self.username = [dictionary jsonObjectForKey:@"username"];
            self.email = [dictionary jsonObjectForKey:@"email"];
            self.publicRepos = [dictionary jsonObjectForKey:@"public_repos"];
            self.blog = [dictionary jsonObjectForKey:@"blog"];
            self.location = [dictionary jsonObjectForKey:@"location"];
            self.publicGists = [dictionary jsonObjectForKey:@"public_gists"];
            self.createdAt = [[dictionary jsonObjectForKey:@"created_at"] dateForRFC3339DateTimeString];
            self.hireable = [[dictionary jsonObjectForKey:@"hireable"] boolValue];
            self.followers = [dictionary jsonObjectForKey:@"followers"];
            self.following = [dictionary jsonObjectForKey:@"following"];
            self.bio = [dictionary jsonObjectForKey:@"bio"];
            self.avatarId = [dictionary jsonObjectForKey:@"gravatar_id"];
            self.url = [dictionary jsonObjectForKey:@"url"];
            if ((self.url == nil || self.url.length == 0) && self.login.length > 0) {
                self.url = [NSString stringWithFormat:@"https://api.github.com/users/%@", self.login];
            }
        }
        if (self.avatarUrl == nil && avatarId != nil) {
            self.avatarUrl = [NSString stringWithFormat:@"https://secure.gravatar.com/avatar/%@", avatarId];
        }        
    }
    return self;
}


- (id)initWithJSONObject:(NSDictionary*)dictionary JSONObject:(NSDictionary*)secondDictionary {
    self = [super init];
    if (self) {
        if (dictionary != nil && ![dictionary isEqual:[NSNull null]]) {
            self.login = [dictionary jsonObjectForKey:@"login"];
            self.name = [dictionary jsonObjectForKey:@"name"];
            self.email = [dictionary jsonObjectForKey:@"email"];
            self.avatarUrl = [dictionary jsonObjectForKey:@"avatar_url"];
            self.avatarId = [dictionary jsonObjectForKey:@"gravatar_id"];
        }
        if (![secondDictionary isEqual:[NSNull null]]) {
            if (self.login == nil) {
                self.login = [secondDictionary jsonObjectForKey:@"login"];
            }
            if (self.name == nil) {
                self.name = [secondDictionary jsonObjectForKey:@"name"];
            }
            if (self.email == nil) {
                self.email = [secondDictionary jsonObjectForKey:@"email"];
            }
            if (self.avatarUrl == nil) {
                self.avatarUrl = [secondDictionary jsonObjectForKey:@"avatar_url"];
            }
            if (self.avatarId == nil) {
                self.avatarId = [secondDictionary jsonObjectForKey:@"garavatr_id"];
            }
        }
        if ((self.url == nil || self.url.length == 0) && self.login.length > 0) {
            self.url = [NSString stringWithFormat:@"https://api.github.com/users/%@", self.login];
        }
        if (self.avatarUrl == nil && avatarId != nil) {
            self.avatarUrl = [NSString stringWithFormat:@"https://secure.gravatar.com/avatar/%@?d=https://a248.e.akamai.net/assets.github.com/images/gravatars/gravatar-140.png", avatarId];
        }
    }
    return self;
}

-(id)initWithLogin:(NSString *)aLogin {
    self = [super init];
    if (self) {
        self.login = aLogin;
        self.url = [NSString stringWithFormat:@"https://api.github.com/users/%@", self.login];
    }
    return self;
}

-(void)loadImageIntoImageView:(UIImageView*)imageView {
    if (avatarUrl != nil) {
        long mySequenceNumber = sequenceCounter++;
        
        [image2SequenceNumber setObject:[NSNumber numberWithLong:mySequenceNumber] forKey:[NSNumber numberWithUnsignedInteger:imageView.hash]];
        id image = [url2Image objectForKey:self.avatarUrl];
        if (image == [NSNull null]) {
            return;
        } else if (image != nil) {
            imageView.layer.cornerRadius = 10.0f;
            imageView.layer.masksToBounds = YES;
            imageView.image = image;
            return;
        }

        [[NetworkProxy sharedInstance] 
         loadStringFromURL:avatarUrl 
         verb:@"GET"
         block:^(int statusCode, NSDictionary *aHeaderFields, id data) {
             if (statusCode == 200) {
                 UIImage *image = nil;
                 if ([data isKindOfClass:[UIImage class]]) {
                     image = data;
                 } else if ([data isKindOfClass:[NSData class]]) {
                     image = [UIImage imageWithData:data];
                 }
                 [url2Image setObject:image forKey:self.avatarUrl];
                 NSNumber* sequenceNumber = [image2SequenceNumber objectForKey:[NSNumber numberWithUnsignedInteger:imageView.hash]];
                 if ([sequenceNumber longValue] == mySequenceNumber) {
                     dispatch_sync(dispatch_get_main_queue(), ^() {
                         imageView.layer.cornerRadius = 10.0f;
                         imageView.layer.masksToBounds = YES;
                         imageView.image = image;
                     });
                     [image2SequenceNumber removeObjectForKey:[NSNumber numberWithUnsignedInteger:imageView.hash]];
                 }
             } else {
                 [url2Image setObject:[NSNull null] forKey:self.avatarUrl];
     
             }
         }
         errorBlock:^(NSError* error) {
             // Ignore, it's only images.
         }];
    }

}

+(void)clearCache {
    [url2Image removeAllObjects];
    [image2SequenceNumber removeAllObjects];
}

-(NSString*)displayname {
    
    if (self.name) {
        return [self.name description];
    } else if (self.login) {
        return [self.login description];
    } else if (self.username) {
        return [self.username description];
    }
    return nil;
}



@end
