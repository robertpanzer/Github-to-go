//
//  Settings.m
//  Github To Go
//
//  Created by Robert Panzer on 08.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Settings.h"

static Settings* sharedInstance = nil;

static NSURLProtectionSpace* protectionSpace = nil;

@interface Settings()

- (void)setCredentialsUser:(NSString*)aUsername password:(NSString*)aPassword;
- (void)loadSettingsFromFile;
- (void)storeSettingsToFile;
@end

@implementation Settings

@synthesize passwordValidated;

+ (Settings *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[Settings alloc] init];
    }
    return sharedInstance;
}


- (id)init {
    self = [super init];
    if (self) {
        // TODO: Load from file
        [self loadSettingsFromFile];
        
        protectionSpace = [[NSURLProtectionSpace alloc] initWithHost:@"api.github.com" 
                                                                 port:443 
                                                             protocol:@"https" 
                                                                realm:@"GitHub" 
                                                authenticationMethod:nil];
                          
        
        NSURLCredential* credential = [[NSURLCredentialStorage sharedCredentialStorage] defaultCredentialForProtectionSpace:protectionSpace];
        password = credential.password;
    }
    return self;
}

- (NSString*)username {
    return [settings objectForKey:@"username"];
}

- (void)setUsername:(NSString*)aUserName {
    if (![self.username isEqualToString:aUserName]) {
        [settings setValue:aUserName forKey:@"username"];
        [self setCredentialsUser:aUserName password:nil];
        [self storeSettingsToFile];
    }
}

- (NSString*) password {
    NSURLCredentialStorage* credentialStorage = [NSURLCredentialStorage sharedCredentialStorage];
    NSURLCredential* credential = [credentialStorage defaultCredentialForProtectionSpace:protectionSpace];
    return credential.password;
}

- (void) setPassword:(NSString *)aPassword {
    if (password != aPassword) {
        password = aPassword;
        [self setCredentialsUser:self.username password:aPassword];
    }
}

- (void)setCredentialsUser:(NSString*)aUserName password:(NSString*)aPassword {
    // First delete old credentials, so that prior, even working credentials do not work any more.
    NSURLCredentialStorage* credentialStorage = [NSURLCredentialStorage sharedCredentialStorage];
    NSDictionary* credentials = [credentialStorage credentialsForProtectionSpace:protectionSpace];
    for (NSURLCredential* credential in credentials.objectEnumerator) {
        [credentialStorage removeCredential:credential forProtectionSpace:protectionSpace];
    }
    
    if (aUserName != nil && aUserName.length > 0 && aPassword != nil && aPassword.length > 0) {

        NSURLCredential* credential = [[NSURLCredential alloc] initWithUser:aUserName
                                                                    password:aPassword
                                                                 persistence:NSURLCredentialPersistencePermanent];
        
        [credentialStorage setDefaultCredential:credential forProtectionSpace:protectionSpace];        
    }
    
    credentials = [credentialStorage credentialsForProtectionSpace:protectionSpace];

    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

-(BOOL) isUsernameSet {
    return self.username != nil && self.username.length > 0;
}

- (void) loadSettingsFromFile {
    NSString *path;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	path = [paths objectAtIndex:0];
	path = [path stringByAppendingPathComponent:@"Settings.plist"];
	if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        settings = [[NSMutableDictionary alloc] initWithContentsOfFile:path];    
    } else {
        settings = [[NSMutableDictionary alloc] init];
    }
}

- (void) storeSettingsToFile {
    NSString *path;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	path = [paths objectAtIndex:0];
	path = [path stringByAppendingPathComponent:@"Settings.plist"];
    [settings writeToFile:path atomically:YES];
}

@end
