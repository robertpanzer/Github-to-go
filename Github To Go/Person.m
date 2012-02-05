//
//  Person.m
//  Github To Go
//
//  Created by Robert Panzer on 04.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Person.h"
#import "NetworkProxy.h"

static NSDictionary* url2Image;

@implementation Person 

@synthesize login;
@synthesize name;
@synthesize email;
@synthesize avatarUrl;

+ (void)initialize {
    url2Image = [[NSMutableDictionary alloc] init];
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
        UIImage* image = [url2Image objectForKey:self.avatarUrl];
        if (image != nil) {
            imageView.image = image;
            return;
        }
        NSLog(@"url2Image: %d", url2Image.count);
        [[NetworkProxy sharedInstance] loadStringFromURL:avatarUrl block:^(int statusCode, NSDictionary *aHeaderFields, id data) {
            if ([data isKindOfClass:[UIImage class]]) {
                [url2Image setValue:data forKey:self.avatarUrl];
                imageView.image = data;
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
