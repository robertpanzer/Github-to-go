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

- (void)setCredentials;
- (void)loadSettingsFromFile;
- (void)storeSettingsToFile;
@end

@implementation Settings

+ (Settings *)sharedInstance {
    if (sharedInstance == nil) {
        Settings* newSettings = [[Settings alloc] init];
        sharedInstance = newSettings;
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
        password = [credential.password retain];
    }
    return self;
}

- (NSString*)username {
    return [settings objectForKey:@"username"];
}

- (void)setUsername:(NSString*)aUserName {
    [settings setValue:aUserName forKey:@"username"];
    [self setCredentials];
    [self storeSettingsToFile];
}

- (NSString*) password {
    return password;
}

- (void) setPassword:(NSString *)aPassword {
    if (password != aPassword) {
        [password release];
        password = [aPassword retain];
        [self setCredentials];
    }
}

- (void)setCredentials {
    // First delete old credentials, so that prior, even working credentials do not work any more.
    NSURLCredentialStorage* credentialStorage = [NSURLCredentialStorage sharedCredentialStorage];
    NSDictionary* credentials = [credentialStorage credentialsForProtectionSpace:protectionSpace];
    for (NSURLCredential* credential in credentials.objectEnumerator) {
        [credentialStorage removeCredential:credential forProtectionSpace:protectionSpace];
    }
    
    if (self.username != nil && self.username.length > 0 && self.password != nil && self.password.length > 0) {

        NSURLCredential* credential = [[[NSURLCredential alloc] initWithUser:self.username
                                                                    password:password
                                                                 persistence:NSURLCredentialPersistencePermanent]
                                       autorelease];
        
        [credentialStorage setDefaultCredential:credential forProtectionSpace:protectionSpace];        
    }
    
    credentials = [credentialStorage credentialsForProtectionSpace:protectionSpace];
    for (NSURLCredential* credential in credentials.objectEnumerator) {
        NSLog(@"Credential for %@", credential.user);
    }

    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void) loadSettingsFromFile {
    NSString *path;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	path = [paths objectAtIndex:0];
	path = [path stringByAppendingPathComponent:@"Settings"];
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
	path = [path stringByAppendingPathComponent:@"Settings"];
    [settings writeToFile:path atomically:YES];
}

-(NSUInteger)retainCount {
    return NSIntegerMax;
}

@end
