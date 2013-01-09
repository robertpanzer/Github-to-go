//
//  NetworkProxy.h
//  TabBarTest
//
//  Created by Robert Panzer on 31.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NetworkProxy : NSObject  

@property(strong) NSMutableSet* connectionDataSet;
@property(strong) NSOperationQueue* operationQueue;
@property NSUInteger openConnections;
@property NSInteger rateLimit;

+(NetworkProxy*) sharedInstance;

-(void)loadStringFromURL:(NSString*)url block:(void(^)(int statusCode, NSDictionary* aHeaderFields, id data) ) block;

-(void)loadStringFromURL:(NSString*)url verb:(NSString*)aVerb block:(void(^)(int statusCode, NSDictionary* aHeaderFields, id data) ) block;

-(void)loadStringFromURL:(NSString*)urlString block:(void(^)(int statusCode, NSDictionary* aHeaderFields, id data) ) block errorBlock:(void(^)(NSError*))errorBlock;

-(void)loadStringFromURL:(NSString*)urlString verb:(NSString*)aVerb block:(void(^)(int statusCode, NSDictionary* aHeaderFields, id data) ) block errorBlock:(void(^)(NSError*))errorBlock;

-(void)loadStringFromURL:(NSString*)urlString verb:(NSString*)aVerb headerFields:(NSDictionary*)headerFields block:(void(^)(int statusCode, NSDictionary* aHeaderFields, id data) ) block errorBlock:(void(^)(NSError*))errorBlock;

-(void)sendData:(id)date ToUrl:(NSString*)urlString verb:(NSString*)aVerb block:(void(^)(int statusCode, NSDictionary* aHeaderFields, id data) ) block errorBlock:(void(^)(NSError*))errorBlock;

@end

@interface NSString(RPContentType)

-(BOOL)contentTypeIsText;

@end