//
//  GithubNotification.m
//  Hub To Go
//
//  Created by Robert Panzer on 10.02.13.
//
//

#import "GithubNotification.h"
#import "NSString+ISO8601Parsing.h"

@implementation GithubNotification


- (id)initWithJsonObject:(NSDictionary*)jsonDictionary
{
    self = [super init];
    if (self) {
        _id = jsonDictionary[@"id"];
        _unread = [((NSNumber*)jsonDictionary[@"unread"]) boolValue];
        _reason = jsonDictionary[@"reason"];
        _updatedAt = [jsonDictionary[@"updated_at"] dateForRFC3339DateTimeString];
        _lastReadAt = [jsonDictionary[@"updated_at"] dateForRFC3339DateTimeString];
        _title = [jsonDictionary valueForKeyPath:@"subject.title"];
        _type = [jsonDictionary valueForKeyPath:@"subject.type"];
        _url = [jsonDictionary valueForKeyPath:@"subject.url"];
        _repository = [[Repository alloc] initFromJSONObject:jsonDictionary[@"repository"]];
    }
    return self;
}
@end
