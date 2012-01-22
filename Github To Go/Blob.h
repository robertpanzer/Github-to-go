//
//  Blob.h
//  Github To Go
//
//  Created by Robert Panzer on 05.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Blob : NSObject {
    NSString* absolutePath;
    NSString* url;
    long size;
    NSString* content;

}

@property(readonly) NSString* name;
@property(readonly, strong) NSString* absolutePath;
@property(strong) NSString* url;
@property(strong) NSString* content;
@property(readonly) long size;

-(id)initWithJSONObject:(NSDictionary*)jsonObject absolutePath:(NSString*)anAbsolutePath;

@end
