//
//  RPWatchRepoActivity.m
//  Hub To Go
//
//  Created by Robert Panzer on 14.10.12.
//
//

#import "RPWatchRepoActivity.h"
#import "RepositoryStorage.h"
#import "NetworkProxy.h"


static NSString* WatchRepo;
static NSString* StopWatchingRepo;

@implementation RPWatchRepoActivity


+(void) initialize {
    WatchRepo = NSLocalizedString(@"Watch Repository", @"Action Sheet Watch Repo");
    StopWatchingRepo = NSLocalizedString(@"Stop watching", @"Action Sheet Stop Watching");
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
    if (![[RepositoryStorage sharedStorage] repositoryIsWatched:self.repository]) {
        return [UIImage imageNamed:@"follow"];
    } else {
        return [UIImage imageNamed:@"unfollow"];
    }
}

-(NSString *)activityTitle {
    if (![[RepositoryStorage sharedStorage] repositoryIsWatched:self.repository]) {
        return NSLocalizedString(@"Watch", @"Watch");
    } else {
        return NSLocalizedString(@"Unwatch", @"Unwatch");
    }
}

-(NSString *)activityType {
    return @"Follow";
}

-(BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return ![[RepositoryStorage sharedStorage] repositoryIsOwned:self.repository];
}

-(void)prepareWithActivityItems:(NSArray *)activityItems {
    
}

-(void)performActivity {
    NSString* url = [NSString stringWithFormat:@"https://api.github.com/repos/%@/subscription", self.repository.fullName];
    if (![[RepositoryStorage sharedStorage] repositoryIsWatched:self.repository]) {
        [[NetworkProxy sharedInstance] sendData:@{@"subscribed": @YES} ToUrl:url verb:@"PUT" block:^(int status, NSDictionary* headerFields, id data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == 200) {
                    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:WatchRepo message:NSLocalizedString(@"Repository is being watched now", @"Alert View") delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [alertView show];
                    [[RepositoryStorage sharedStorage] addWatchedRepository:self.repository];
                    [self activityDidFinish:YES];
                } else {
                    NSString *errMsg = nil;
                    if ([data isKindOfClass:[NSDictionary class]]) {
                        errMsg = data[@"message"];
                    }
                    NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"Starting to watch repository failed %d: %@", @"Alert view"), status, errMsg];
                    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:WatchRepo message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [alertView show];
                    [self activityDidFinish:NO];
                }
            });
        }
                                     errorBlock: nil];
    } else {
        [[NetworkProxy sharedInstance] loadStringFromURL:url verb:@"DELETE" block:^(int status, NSDictionary* headerFields, id data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == 204) {
                    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:StopWatchingRepo message:NSLocalizedString(@"Repository is no longer watched now", @"Alert view") delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [alertView show];
                    [[RepositoryStorage sharedStorage] removeWatchedRepository:self.repository];
                    [self activityDidFinish:YES];
                } else {
                    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:StopWatchingRepo message:NSLocalizedString(@"Stopping to watch repository failed", @"Alert view") delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [alertView show];
                    [self activityDidFinish:NO];
                }
            });
        }];
    }
}


@end
