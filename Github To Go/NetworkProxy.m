//
//  NetworkProxy.m
//  TabBarTest
//
//  Created by Robert Panzer on 31.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NetworkProxy.h"
#import <UIKit/UIKit.h>
#import "NSData+Base64.h"
#import "Settings.h"

static NetworkProxy* networkProxyInstance;

@interface ConnectionData : NSObject {
@private
    NSNumber* statusCode;
    NSURLConnection* connection;
    NSMutableData* receivedData;
    NSString* url;
    NSDictionary* headerFields;
    void (^block)(int, NSDictionary*, id);
    void (^errorBlock)(NSError*);
}
@property(strong) NSNumber* statusCode;
@property(strong) NSURLConnection* connection;
@property(strong) NSMutableData* receivedData;
@property(strong) NSString* url;
@property(strong) NSDictionary* headerFields;
@property(nonatomic, copy) void (^block)(int, NSDictionary*, id);
@property(nonatomic, copy) void (^errorBlock)(NSError*);

@end

@implementation ConnectionData 

@synthesize statusCode;
@synthesize connection;
@synthesize receivedData;
@synthesize url;
@synthesize headerFields;
@synthesize block;
@synthesize errorBlock;


- (id)initWithUrl:(NSString*)anUrl {
    self = [super init];
    if (self) {
        self.url = anUrl;
    }
    return self;
}


@end

@interface NetworkProxy()  
-(ConnectionData*)connectionDataForConnection:(NSURLConnection*)connection;

-(void)addBasicAuthenticationHeaderToRequest:(NSMutableURLRequest*)request;

-(void)increaseConnectionCount;

-(void)decreaseConnectionCount;

@end

@implementation NetworkProxy

@synthesize connectionDataSet;
@synthesize operationQueue;
@synthesize openConnections;

+(void)initialize {
    networkProxyInstance = [[NetworkProxy alloc] init];
}

+(NetworkProxy*) sharedInstance {
    return networkProxyInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        networkProxyInstance = self;
        self.connectionDataSet = [[NSMutableSet alloc] init];
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.openConnections = 0;
    }
    return self;
}

-(void)loadStringFromURL:(NSString*)urlString block:(void(^)(int statusCode, NSDictionary* aHeaderFields, id data) ) block {
    [self loadStringFromURL:urlString verb:@"GET" block:block];
}

-(void)loadStringFromURL:(NSString*)urlString verb:(NSString*)aVerb block:(void(^)(int statusCode, NSDictionary* aHeaderFields, id data) ) block {
    [self loadStringFromURL:urlString verb:aVerb block:block errorBlock:^(NSError* error) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Network access failed!" message:[error localizedDescription] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alertView show];
    }];
}

-(void)loadStringFromURL:(NSString*)urlString block:(void(^)(int statusCode, NSDictionary* aHeaderFields, id data) ) block errorBlock:(void(^)(NSError*))errorBlock {
    [self loadStringFromURL:urlString verb:@"GET" block:block errorBlock:errorBlock];
}

-(void)loadStringFromURL:(NSString*)urlString verb:(NSString*)aVerb block:(void(^)(int statusCode, NSDictionary* aHeaderFields, id data) ) block errorBlock:(void(^)(NSError*))errorBlock {
        
    [self increaseConnectionCount];
    
    NSString* escapedUrlString = [[urlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    NSURL* url = [[NSURL alloc] initWithString:escapedUrlString];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.timeoutInterval = 30;
    request.HTTPMethod = aVerb;
    [self addBasicAuthenticationHeaderToRequest:request];

    
    ConnectionData* connectionData = [[ConnectionData alloc] initWithUrl:urlString];
    connectionData.receivedData = [[NSMutableData alloc] init];
    connectionData.block = block;
    connectionData.errorBlock = errorBlock;
    [connectionDataSet addObject:connectionData];

    connectionData.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];  
}

-(void)sendData:(id)data ToUrl:(NSString*)urlString verb:(NSString*)aVerb block:(void(^)(int statusCode, NSDictionary* aHeaderFields, id data) ) block errorBlock:(void(^)(NSError*))errorBlock {

    [self increaseConnectionCount];

    NSString* escapedUrlString = [[urlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];

    NSURL* url = [NSURL URLWithString:escapedUrlString];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.timeoutInterval = 10;
    request.HTTPMethod = aVerb;
    
    NSData* nsData = nil;
    if ([data isKindOfClass:[NSDictionary class]]) {
        NSError* error = nil;
        nsData = [NSJSONSerialization dataWithJSONObject:data options:0 error:&error];
        if (error != nil) {
            dispatch_async(dispatch_get_main_queue(), ^(){
                errorBlock(error); 
            });
            return;
        }
        [self addBasicAuthenticationHeaderToRequest:request];
    }
    request.HTTPBody = nsData;

    
    ConnectionData* connectionData = [[ConnectionData alloc] initWithUrl:urlString];
    connectionData.receivedData = [[NSMutableData alloc] init];
    connectionData.block = block;
    connectionData.errorBlock = errorBlock;
    [connectionDataSet addObject:connectionData];
    
    connectionData.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];  
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self decreaseConnectionCount];
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    
    ConnectionData* connectionData = [self connectionDataForConnection:connection];
    NSMutableData* receivedData = connectionData.receivedData;
//    SBJsonParser* parser = [[SBJsonParser alloc] init];
//    id object = [parser objectWithData:receivedData];

    void(^block)(int, NSDictionary*, id) = connectionData.block;
    
    [operationQueue addOperationWithBlock:^() {
        NSError* error;
        NSString* contentType = [connectionData.headerFields objectForKey:@"Content-Type"];
        id object = nil;
        if ([contentType rangeOfString:@"application/json"].location != NSNotFound) {
            object = [NSJSONSerialization JSONObjectWithData:receivedData options:0 error:&error];
//        } else if ([contentType rangeOfString:@"image/"].location != NSNotFound) {
//            object = [UIImage imageWithData:receivedData];
        } else if ([contentType rangeOfString:@"text/plain"].location != NSNotFound) {
            object = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
            if (object == nil) {
                dispatch_async(dispatch_get_main_queue(), ^(){
                    connectionData.errorBlock(nil); 
                });
                return;
            }
        } else {
            object = receivedData;
        }
        if ([@"api.github.com" isEqualToString:connection.originalRequest.URL.host]) {
            if ([connectionData.statusCode intValue]< 400) {
                [Settings sharedInstance].passwordValidated = [NSNumber numberWithBool:YES];
            } else {
                [Settings sharedInstance].passwordValidated = [NSNumber numberWithBool:NO];
            }
        }

        block([connectionData.statusCode intValue], connectionData.headerFields, object);
    }];    
    // release the connection, and the data object
    //Block_release(connectionData.block);
    connectionData.block = nil;
    [connectionDataSet removeObject:connectionData];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //    NSString* dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //    NSLog(@"Data:\n%@", dataString);
    //    [dataString release];
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    ConnectionData* connectionData = [self connectionDataForConnection:connection];
    [connectionData.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
    
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    
    // receivedData is an instance variable declared elsewhere.
    ConnectionData* connectionData = [self connectionDataForConnection:connection];
    connectionData.statusCode = [NSNumber numberWithInteger:httpResponse.statusCode];
    connectionData.headerFields = httpResponse.allHeaderFields;
    [connectionData.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self decreaseConnectionCount];
    NSLog(@"Failed: %@", error);
    ConnectionData* connectionData = [self connectionDataForConnection:connection];
    dispatch_async(dispatch_get_main_queue(), ^{
        connectionData.errorBlock(error);
    });
}

-(void)connection:(NSURLConnection *)connection
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge previousFailureCount] == 0) {
        NSURLCredentialStorage* credentialStorage = [NSURLCredentialStorage sharedCredentialStorage];
        NSURLCredential* credential = [credentialStorage defaultCredentialForProtectionSpace:[challenge protectionSpace]];
        if (credential != nil) {
            [[challenge sender] useCredential:credential
                   forAuthenticationChallenge:challenge];
            return;
        }
    }
    if ([@"api.github.com" isEqualToString:connection.originalRequest.URL.host]) {
        [Settings sharedInstance].passwordValidated = [NSNumber numberWithBool:NO];
    }
    [[challenge sender] cancelAuthenticationChallenge:challenge];
}
                           
- (ConnectionData*)connectionDataForConnection:(NSURLConnection*)connection {
    for (ConnectionData* connectionData in connectionDataSet) {
        if (connectionData.connection == connection) {
            return connectionData;
        }
    }
    return nil;
}
        
-(void)addBasicAuthenticationHeaderToRequest:(NSMutableURLRequest*)request {
    if ([@"api.github.com" isEqualToString:request.URL.host] 
        && [Settings sharedInstance].username != nil && [[Settings sharedInstance].username length] > 0) {
        NSData *passwordData = [[NSString stringWithFormat:@"%@:%@", [Settings sharedInstance].username, [Settings sharedInstance].password] dataUsingEncoding:NSASCIIStringEncoding];
        NSString *pwd = [NSString stringWithFormat:@"Basic %@", [passwordData base64EncodingWithLineLength:1024]];
        [request setValue:pwd forHTTPHeaderField:@"Authorization"];
    }
}

-(void)increaseConnectionCount {
    self.openConnections++;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

-(void)decreaseConnectionCount {
    if (self.openConnections > 0) {
        self.openConnections --;
    }
    if (self.openConnections <= 0) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

@end
