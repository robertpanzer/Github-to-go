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

- (id)initWithJSONObject:(NSDictionary*)dictionary JSONObject:(NSDictionary*)secondDictionary {
    self = [super init];
    if (self) {
        if (dictionary != nil && ![dictionary isEqual:[NSNull null]]) {
            self.login = [dictionary objectForKey:@"login"];
            self.name = [dictionary objectForKey:@"name"];
            self.email = [dictionary objectForKey:@"email"];
            self.avatarUrl = [dictionary objectForKey:@"avatar_url"];
        }
        if (![secondDictionary isEqual:[NSNull null]]) {
            if (self.avatarUrl == nil) {
                self.avatarUrl = [secondDictionary objectForKey:@"avatar_url"];
            }
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
        NSLog(@"url2Image: %d", url2Image.count);
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

- (void)dealloc {
    [login release];
    [name release];
    [email release];
    [avatarUrl release];
    [super dealloc];
}
@end
