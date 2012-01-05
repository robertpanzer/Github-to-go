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
    void (^block)(int, id);
}
@property(strong) NSNumber* statusCode;
@property(strong) NSURLConnection* connection;
@property(strong) NSMutableData* receivedData;
@property(strong) NSString* url;
@property(weak) void (^block)(int, id);
@end

@implementation ConnectionData 

@synthesize statusCode;
@synthesize connection;
@synthesize receivedData;
@synthesize url;
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

-(void)loadStringFromURL:(NSString*)urlString block:(void(^)(int statusCode, id data) ) block {
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
    id object = [NSJSONSerialization JSONObjectWithData:receivedData options:0 error:&error];
                 
    void(^block)(int statusCode, id data) = connectionData.block;
    block([connectionData.statusCode intValue], object);
    
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
    [connectionData.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Failed: %@", error);
    UIAlertView* alertView = [[[UIAlertView alloc] initWithTitle:@"Network access failed!" message:[error localizedFailureReason] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil] autorelease];
    [alertView show];
}

-(void)connection:(NSURLConnection *)connection
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    NSLog(@"didReceiveAuthenticationChallenge %@", challenge);
    if ([challenge previousFailureCount] == 0) {
        NSURLCredentialStorage* credentialStorage = [NSURLCredentialStorage sharedCredentialStorage];
        NSURLCredential* credential = [credentialStorage defaultCredentialForProtectionSpace:[challenge protectionSpace]];
        if (credential == nil) {
//            UIAlertView* passwordView = [[UIAlertView alloc] initWithTitle:@"Authentication" message:@"Please enter authentication data" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            passwordView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
//            [passwordView show];
//            NSString* user = [[passwordView textFieldAtIndex:0] text];
//            NSString* password = [[passwordView textFieldAtIndex:1] text];
            credential = [NSURLCredential credentialWithUser:@"robertpanzer"
                                                    password:@"Blaumeise01"
                                                 persistence:NSURLCredentialPersistenceForSession];
//            NSLog(@"User: %@", user);
//            [passwordView release];
        }
//        newCredential = [NSURLCredential credentialWithUser:@"robertpanzer"
//                                                   password:@"Blaumeise02"
//                                                persistence:NSURLCredentialPersistenceNone];
        [[challenge sender] useCredential:credential
               forAuthenticationChallenge:challenge];
    } else {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
//        UIAlertView* alertView = [[[UIAlertView alloc] initWithTitle:@"Authentication failed" message:@"Wrong password or unknown user!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil] autorelease];
//        [alertView show];
        // inform the user that the user name and password
        // in the preferences are incorrect
        // [self showPreferencesCredentialsAreIncorrectPanel:self];
    }
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
