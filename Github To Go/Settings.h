//
//  Settings.h
//  Github To Go
//
//  Created by Robert Panzer on 08.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Settings : NSObject {
    
    NSDictionary* settings;
    
    NSString* password;
}

@property(strong) NSString* username;
@property(strong) NSString* password;

+ (Settings*) sharedInstance;

@end
