//
//  NetworkProxy.m
//  TabBarTest
//
//  Created by Robert Panzer on 31.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NetworkProxy.h"
#import <UIKit/UIKit.h>

static NetworkProxy* networkProxyInstance;

@interface ConnectionData : NSObject {
@private
    NSNumber* statusCode;
    NSURLConnection* connection;
    NSMutableData* receivedData;
    NSString* url;
    NSDictionary* headerFields;
    void (^block)(int, NSDictionary*, id);
}
@property(strong) NSNumber* statusCode;
@property(strong) NSURLConnection* connection;
@property(strong) NSMutableData* receivedData;
@property(strong) NSString* url;
@property(strong) NSDictionary* headerFields;
@property(weak) void (^block)(int, NSDictionary*, id);
@end

@implementation ConnectionData 

@synthesize statusCode;
@synthesize connection;
@synthesize receivedData;
@synthesize url;
@synthesize headerFields;
@synthesize block;


- (id)initWithUrl:(NSString*)anUrl {
    self = [super init];
    if (self) {
        self.url = anUrl;
    }
    return self;
}

- (void)dealloc {
    [statusCode release];
    [connection release];
    [receivedData release];
    [url release];
    [super dealloc];
}

@end

@interface NetworkProxy()  
-(ConnectionData*)connectionDataForConnection:(NSURLConnection*)connection;
@end

@implementation NetworkProxy

@synthesize connectionDataSet;

+(NetworkProxy*) sharedInstance {
    return networkProxyInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        NSLog(@"Init %@", self);
        networkProxyInstance = self;
        self.connectionDataSet = [[[NSMutableSet alloc] init] autorelease];
    }
    return self;
}

-(void)loadStringFromURL:(NSString*)urlString block:(void(^)(int statusCode, NSDictionary* aHeaderFields, id data) ) block {
    NSURL* url = [NSURL URLWithString:urlString];
    NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    NSLog(@"Request %@", request);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    ConnectionData* connectionData = [[[ConnectionData alloc] initWithUrl:urlString] autorelease];
    connectionData.connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];    
    connectionData.receivedData = [[[NSMutableData alloc] init] autorelease];
    connectionData.block = Block_copy(block);
    [connectionDataSet addObject:connectionData];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    ConnectionData* connectionData = [self connectionDataForConnection:connection];
    NSMutableData* receivedData = connectionData.receivedData;
    NSLog(@"Received %d bytes", receivedData.length);
//    SBJsonParser* parser = [[SBJsonParser alloc] init];
//    id object = [parser objectWithData:receivedData];
    NSError* error = [[[NSError alloc] init] autorelease];
    NSLog(@"HeaderFields: \n%@", connectionData.headerFields);
    NSString* contentType = [connectionData.headerFields objectForKey:@"Content-Type"];
    id object = nil;
    if ([contentType rangeOfString:@"application/json"].location != NSNotFound) {
        object = [NSJSONSerialization JSONObjectWithData:receivedData options:0 error:&error];
    } else if ([contentType rangeOfString:@"image/"].location != NSNotFound) {
        object = [UIImage imageWithData:receivedData];
    }
                 
    void(^block)(int statusCode, NSDictionary* headerFields, id data) = connectionData.block;
    block([connectionData.statusCode intValue], connectionData.headerFields, object);
    
    // release the connection, and the data object
    Block_release(connectionData.block);
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
    NSLog(@"Response : %d", httpResponse.statusCode);
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
    NSLog(@"Failed: %@", error);
    UIAlertView* alertView = [[[UIAlertView alloc] initWithTitle:@"Network access failed!" message:[error localizedDescription] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil] autorelease];
    [alertView show];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(void)connection:(NSURLConnection *)connection
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    NSLog(@"didReceiveAuthenticationChallenge %@", challenge);
    if ([challenge previousFailureCount] == 0) {
        NSURLCredentialStorage* credentialStorage = [NSURLCredentialStorage sharedCredentialStorage];
        NSURLCredential* credential = [credentialStorage defaultCredentialForProtectionSpace:[challenge protectionSpace]];
        if (credential != nil) {
            [[challenge sender] useCredential:credential
                   forAuthenticationChallenge:challenge];
            return;
        }
    }
    [[challenge sender] cancelAuthenticationChallenge:challenge];
    UIAlertView* alertView = [[[UIAlertView alloc] initWithTitle:@"Authentication failed" message:@"Wrong password or unknown user!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil] autorelease];
    [alertView show];
}

- (void)dealloc {
    [self.connectionDataSet release];
    [super dealloc];
}
                           
- (ConnectionData*)connectionDataForConnection:(NSURLConnection*)connection {
    for (ConnectionData* connectionData in connectionDataSet) {
        if (connectionData.connection == connection) {
            return connectionData;
        }
    }
    return nil;
}
                           
@end
