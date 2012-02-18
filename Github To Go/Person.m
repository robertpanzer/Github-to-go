//
//  Person.m
//  Github To Go
//
//  Created by Robert Panzer on 04.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Person.h"
#import "NetworkProxy.h"

static NSMutableDictionary* url2Image;

static NSMutableDictionary* image2SequenceNumber;

static long sequenceCounter = 0;

@implementation Person 

@synthesize login;
@synthesize name;
@synthesize email;
@synthesize avatarUrl;

+ (void)initialize {
    url2Image = [[NSMutableDictionary alloc] init];
    image2SequenceNumber = [[NSMutableDictionary alloc] init];
}

- (id)initWithJSONObject:(NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        NSString* avatarId = nil;
        if (dictionary != nil && ![dictionary isEqual:[NSNull null]]) {
            self.login = [dictionary objectForKey:@"login"];
            self.name = [dictionary objectForKey:@"name"];
            self.email = [dictionary objectForKey:@"email"];
            avatarId = [dictionary objectForKey:@"gravatar_id"];
        }
        if (self.avatarUrl == nil && avatarId != nil) {
            self.avatarUrl = [NSString stringWithFormat:@"https://secure.gravatar.com/avatar/%@?d=https://a248.e.akamai.net/assets.github.com/images/gravatars/gravatar-140.png", avatarId];
        }
        
    }
    return self;
}


- (id)initWithJSONObject:(NSDictionary*)dictionary JSONObject:(NSDictionary*)secondDictionary {
    self = [super init];
    if (self) {
        NSString* avatarId = nil;
        if (dictionary != nil && ![dictionary isEqual:[NSNull null]]) {
            self.login = [dictionary objectForKey:@"login"];
            self.name = [dictionary objectForKey:@"name"];
            self.email = [dictionary objectForKey:@"email"];
//            self.avatarUrl = [dictionary objectForKey:@"avatar_url"];
            avatarId = [dictionary objectForKey:@"gravatar_id"];
        }
        if (![secondDictionary isEqual:[NSNull null]]) {
//            if (self.avatarUrl == nil) {
//                self.avatarUrl = [secondDictionary objectForKey:@"avatar_url"];
//            }
            if (avatarId == nil) {
                avatarId = [secondDictionary objectForKey:@"garavatr_id"];
            }
        }
        if (self.avatarUrl == nil && avatarId != nil) {
            self.avatarUrl = [NSString stringWithFormat:@"https://secure.gravatar.com/avatar/%@?d=https://a248.e.akamai.net/assets.github.com/images/gravatars/gravatar-140.png", avatarId];
        }
    }
    return self;
}

-(void)loadImageIntoImageView:(UIImageView*)imageView {
    if (avatarUrl != nil) {
        long mySequenceNumber = sequenceCounter++;
        
        [image2SequenceNumber setObject:[NSNumber numberWithLong:mySequenceNumber] forKey:[NSNumber numberWithUnsignedInteger:imageView.hash]];
        UIImage* image = [url2Image objectForKey:self.avatarUrl];
        if (image != nil) {
            imageView.image = image;
            return;
        }
        [[NetworkProxy sharedInstance] loadStringFromURL:avatarUrl block:^(int statusCode, NSDictionary *aHeaderFields, id data) {
            if ([data isKindOfClass:[UIImage class]]) {
                [url2Image setValue:data forKey:self.avatarUrl];
                NSNumber* sequenceNumber = [image2SequenceNumber objectForKey:[NSNumber numberWithUnsignedInteger:imageView.hash]];
                if ([sequenceNumber longValue] == mySequenceNumber) {
                    imageView.image = data;
                    [image2SequenceNumber removeObjectForKey:[NSNumber numberWithUnsignedInteger:imageView.hash]];
                }
            }
        }];
    }

}

+(void)clearCache {
    [url2Image removeAllObjects];
    [image2SequenceNumber removeAllObjects];
}

-(NSString*)displayname {
    if (self.name) {
        return self.name;
    } else if (self.login) {
        return self.login;
    } else {
        return self.login;
    }
}



@end
