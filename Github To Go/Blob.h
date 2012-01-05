//
//  Blob.h
//  Github To Go
//
//  Created by Robert Panzer on 05.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Blob : NSObject {
    NSString* name;
    NSString* url;
    long size;

}

@property(strong) NSString* name;
@property(strong) NSString* url;
@property(readonly) long size;

-(id)initWithJSONObject:(NSDictionary*)jsonObject andName:(NSString*)aName;

@end
