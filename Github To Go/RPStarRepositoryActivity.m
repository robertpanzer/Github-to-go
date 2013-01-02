//
//  RPStarRepositoryActivity.m
//  Hub To Go
//
//  Created by Robert Panzer on 02.01.13.
//
//

#import "RPStarRepositoryActivity.h"
#import "RepositoryStorage.h"
#import "NetworkProxy.h"

static NSString* StarRepo;
static NSString* StopStarringRepo;

@implementation RPStarRepositoryActivity

+(void) initialize {
    StarRepo = NSLocalizedString(@"Star Repository", @"Action Sheet Star Repo");
    StopStarringRepo = NSLocalizedString(@"Stop starring", @"Action Sheet Stop Starring");
}

- (id)initWithRepository:(Repository *)repository
{
    self = [super init];
    if (self) {
        _repository = repository;
    }
    return self;
}


-(UIImage *)activityImage {
    if (![[RepositoryStorage sharedStorage] repositoryIsStarred:self.repository]) {
        return [UIImage imageNamed:@"star"];
    } else {
        return [UIImage imageNamed:@"unstar"];
    }
}

-(NSString *)activityTitle {
    if (![[RepositoryStorage sharedStorage] repositoryIsStarred:self.repository]) {
        return NSLocalizedString(@"Star", @"Star");
    } else {
        return NSLocalizedString(@"Unstar", @"Unstar");
    }
}

-(NSString *)activityType {
    return @"Star";
}

-(BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return ![[RepositoryStorage sharedStorage] repositoryIsOwned:self.repository];
}

-(void)prepareWithActivityItems:(NSArray *)activityItems {
    
}

-(void)performActivity {
    NSString* url = [NSString stringWithFormat:@"https://api.github.com/user/starred/%@", self.repository.fullName];
    if (![[RepositoryStorage sharedStorage] repositoryIsStarred:self.repository]) {
        [[NetworkProxy sharedInstance] loadStringFromURL:url verb:@"PUT" block:^(int status, NSDictionary* headerFields, id data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == 204) {
                    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:StarRepo
                                                                        message:NSLocalizedString(@"Repository is being starred now", @"Alert View")
                                                                       delegate:nil
                                                              cancelButtonTitle:nil
                                                              otherButtonTitles:@"OK", nil];
                    [alertView show];
                    [[RepositoryStorage sharedStorage] addStarredRepository:self.repository];
                    [self activityDidFinish:YES];
                } else {
                    NSString *errMsg = nil;
                    if ([data isKindOfClass:[NSDictionary class]]) {
                        errMsg = data[@"message"];
                    }
                    NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"Starring repository failed %d: %@", @"Alert view"), status, errMsg];
                    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:StarRepo
                                                                        message:msg
                                                                       delegate:nil
                                                              cancelButtonTitle:nil
                                                              otherButtonTitles:@"OK", nil];
                    [alertView show];
                    [self activityDidFinish:NO];
                }
            });
        }];
    } else {
        [[NetworkProxy sharedInstance] loadStringFromURL:url verb:@"DELETE" block:^(int status, NSDictionary* headerFields, id data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == 204) {
                    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:StopStarringRepo
                                                                        message:NSLocalizedString(@"Repository is no longer starred now", @"Alert view")
                                                                       delegate:nil
                                                              cancelButtonTitle:nil
                                                              otherButtonTitles:@"OK", nil];
                    [alertView show];
                    [[RepositoryStorage sharedStorage] removeStarredRepository:self.repository];
                    [self activityDidFinish:YES];
                } else {
                    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:StopStarringRepo
                                                                        message:NSLocalizedString(@"Stopping to star repository failed", @"Alert view")
                                                                       delegate:nil
                                                              cancelButtonTitle:nil
                                                              otherButtonTitles:@"OK", nil];
                    [alertView show];
                    [self activityDidFinish:NO];
                }
            });
        }];
    }
}

@end
