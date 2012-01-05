//
//  Commit.h
//  Github To Go
//
//  Created by Robert Panzer on 04.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Commit : NSObject {
    NSString* treeUrl;
}

@property(strong) NSString* treeUrl;

-(id)initWithJSONObject:(NSDictionary*)jsonObject;
@end
