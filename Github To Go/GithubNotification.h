//
//  GithubNotification.h
//  Hub To Go
//
//  Created by Robert Panzer on 10.02.13.
//
//

#import <Foundation/Foundation.h>
#import "Repository.h"

@interface GithubNotification : NSObject

@property(strong, nonatomic) NSString* id;
@property(strong, nonatomic) NSString* reason;
@property(strong, nonatomic) NSString* title;
@property(strong, nonatomic) NSString* type;
@property(strong, nonatomic) NSString* url;
@property(nonatomic) BOOL unread;
@property(strong, nonatomic) NSDate* updatedAt;
@property(strong, nonatomic) NSDate* lastReadAt;
@property(strong, nonatomic) Repository *repository;

- (id)initWithJsonObject:(NSDictionary*)jsonDictionary;

@end
