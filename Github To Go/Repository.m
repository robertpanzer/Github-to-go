//
//  Repository.m
//  TabBarTest
//
//  Created by Robert Panzer on 30.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Repository.h"
#import "NetworkProxy.h"
#import "NSString+ISO8601Parsing.h"

static dispatch_queue_t dispatch_queue;

@interface Repository ()
    
-(void)extractData:(NSDictionary*)jsonObject;
    
@end

@implementation Repository

+(void) initialize {
    dispatch_queue = dispatch_queue_create("repository_init_fully", DISPATCH_QUEUE_CONCURRENT);
}

-(id) initFromJSONObject:(NSDictionary*)jsonObject {
    self = [super init];
    if (self) {
        self.fullyInitialized = NO;
        [self extractData:jsonObject];
    }
    return self;    
}


-(void) initializeFully:(NSDictionary*)jsonObject {
    if (self.fullyInitialized) {
        return;
    }
    [self extractData:jsonObject];
}

- (void) extractData:(NSDictionary*) jsonObject {
    _name = [jsonObject valueForKey:@"name"];
    _fullName = [jsonObject valueForKey:@"full_name"];

    id ownerObject = [jsonObject valueForKey:@"owner"];
    if ([ownerObject isKindOfClass:[NSString class]]) {
        _owner = [[Person alloc] initWithLogin:ownerObject];
    } else if (ownerObject != nil) {
        _owner = [[Person alloc] initWithJSONObject:ownerObject];
    }

    if ([_name rangeOfString:@"/"].location != NSNotFound) {
        _fullName = _name;
        _name = [_name substringFromIndex:[_name rangeOfString:@"/"].location + 1];
    } else if (_fullName == nil) {
        _fullName = [NSString stringWithFormat:@"%@/%@", _owner.login, _name];
    }
    
    _description = [jsonObject valueForKey:@"description"];
    if (![[jsonObject valueForKey:@"master_branch"] isKindOfClass:[NSNull class]]) {
        _masterBranch = [jsonObject valueForKey:@"master_branch"];
    }
    
    _branches = [[NSMutableDictionary alloc] init];
    
    
    _repoId = [jsonObject valueForKey:@"id"];
    
    _private = [[jsonObject valueForKey:@"private"] boolValue];
    
    _watchers = [jsonObject valueForKey:@"watchers"];
    
    _fork = [[jsonObject valueForKey:@"fork"] boolValue];
    if (_fork) {
        _parentRepo = [jsonObject valueForKeyPath:@"parent.full_name"];
        _parentRepoUrl = [jsonObject valueForKeyPath:@"parent.url"];
    }
    
    _forks = [jsonObject valueForKey:@"forks"];
    
    _url = [jsonObject valueForKey:@"url"];
    if ([_url rangeOfString:@"https://api.github.com/"].location == NSNotFound) {
        _url = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@", jsonObject[@"username"], jsonObject[@"name"]];
    }
    _htmlUrl = [jsonObject valueForKey:@"html_url"];

    _notificationsUrl = jsonObject[@"notifications_url"];
    if (_notificationsUrl != nil) {
        _notificationsUrl = [_notificationsUrl substringToIndex:[_notificationsUrl rangeOfString:@"{"].location];
    } else {
        _notificationsUrl = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/notifications", jsonObject[@"username"], jsonObject[@"name"]];
    }
    
    
    _branchesUrl = jsonObject[@"branches_url"];
    if (_branchesUrl != nil) {
        _branchesUrl = [_branchesUrl substringToIndex:[_branchesUrl rangeOfString:@"{"].location];
    } else {
        _branchesUrl = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/branches", _owner.login, _name];
    }
    
    _eventsUrl = jsonObject[@"events_url"];
    if (_eventsUrl != nil) {
//        _eventsUrl = [_eventsUrl substringToIndex:[_eventsUrl rangeOfString:@"{"].location];
    } else {
        _eventsUrl = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/events", _owner.login, _name];
    }

    _issuesUrl = jsonObject[@"issues_url"];
    if (_issuesUrl != nil) {
        _issuesUrl = [_issuesUrl substringToIndex:[_issuesUrl rangeOfString:@"{"].location];
    } else {
        _issuesUrl = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/issues", _owner.login, _name];
    }

    _pullsUrl = jsonObject[@"pulls_url"];
    if (_pullsUrl != nil) {
        _pullsUrl = [_pullsUrl substringToIndex:[_pullsUrl rangeOfString:@"{"].location];
    } else {
        _pullsUrl = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/pulls", _owner.login, _name];
    }

    _createdAt = [[jsonObject valueForKey:@"created_at"] dateForRFC3339DateTimeString];
    _language = [jsonObject valueForKey:@"language"];
    _openIssues = [jsonObject valueForKey:@"open_issues"];
    
}

- (void)setBranchesFromJSONObject:(NSArray*)jsonArray {
    for (NSDictionary* branch in jsonArray) {
        NSString* branchName = [branch valueForKey:@"name"];
        NSDictionary* commit = [branch valueForKey:@"commit"];
        NSString* commitUrl = [commit valueForKey:@"url"]; 
        [_branches setValue:commitUrl forKey:branchName];
    }
}

- (NSString*) urlOfMasterBranch {
    if (self.branches.count == 0) {
        return nil;
    }
    if (self.masterBranch == nil) {
        return nil;
    }
    return [self.branches valueForKey:self.masterBranch];
}


-(BOOL)matchesSearchString:(NSString *)searchString {
    if ([self.name rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return YES;
    }
    if ([self.owner.login rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return YES;
    }
    return NO;
}
@end
