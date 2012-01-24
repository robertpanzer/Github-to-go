//
//  GitObject.h
//  Github To Go
//
//  Created by Robert Panzer on 23.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GitObject <NSObject>

-(NSString*)commitSha;

-(NSString*) absolutePath;

-(NSString*) name;


@end
