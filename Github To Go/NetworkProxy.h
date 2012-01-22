//
//  NetworkProxy.h
//  TabBarTest
//
//  Created by Robert Panzer on 31.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NetworkProxy : NSObject  {
    NSMutableSet* connectionDataSet;
}

@property(strong) NSMutableSet* connectionDataSet;

+(NetworkProxy*) sharedInstance;

-(void)loadStringFromURL:(NSString*)url block:(void(^)(int statusCode, NSDictionary* aHeaderFields, id data) ) block;

@end
