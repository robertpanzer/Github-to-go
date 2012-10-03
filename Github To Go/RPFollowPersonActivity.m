//
//  RPFollowPersonActivity.m
//  Hub To Go
//
//  Created by Robert Panzer on 30.09.12.
//
//

#import "RPFollowPersonActivity.h"
#import "RepositoryStorage.h"
#import "NetworkProxy.h"

@implementation RPFollowPersonActivity

- (id)initWithPerson:(Person *)person
{
    self = [super init];
    if (self) {
        _person = person;
    }
    return self;
}

-(UIImage *)activityImage {
    if ([[RepositoryStorage sharedStorage].followedPersons objectForKey:self.person.login] == nil) {
        return [UIImage imageNamed:@"follow"];
    } else {
        return [UIImage imageNamed:@"unfollow"];
    }
}

-(NSString *)activityTitle {
    if ([[RepositoryStorage sharedStorage].followedPersons objectForKey:self.person.login] == nil) {
        return NSLocalizedString(@"Follow", @"Follow");
    } else {
        return NSLocalizedString(@"Unfollow", @"Unfollow");
    }
}

-(NSString *)activityType {
    return @"Follow";
}

-(BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

-(void)prepareWithActivityItems:(NSArray *)activityItems {

}

-(void)performActivity {
    NSString* url = [NSString stringWithFormat:@"https://api.github.com/user/following/%@", self.person.login];
    if ([[RepositoryStorage sharedStorage].followedPersons objectForKey:self.person.login] == nil) {
        [[NetworkProxy sharedInstance] loadStringFromURL:url verb:@"PUT" block:^(int status, NSDictionary* headerFields, id data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == 204) {
                    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Follow" message:@"User is being followed now" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [alertView show];
                    [[RepositoryStorage sharedStorage].followedPersons setObject:self.person forKey:self.person.login];
                    [self activityDidFinish:YES];
                } else {
                    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Following user failed" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [alertView show];
                    [self activityDidFinish:NO];
                }
            });
            [[RepositoryStorage sharedStorage] loadFollowed];
        } ];
    } else {
        [[NetworkProxy sharedInstance] loadStringFromURL:url verb:@"DELETE" block:^(int status, NSDictionary* headerFields, id data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == 204) {
                    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Unfollow" message:@"User is no longer followed now" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [alertView show];
                    [[RepositoryStorage sharedStorage].followedPersons removeObjectForKey:self.person.login];
                    [self activityDidFinish:YES];
                } else {
                    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Stopping to follow user failed" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [alertView show];
                    [self activityDidFinish:NO];
                }
            });
            [[RepositoryStorage sharedStorage] loadFollowed];
        } ];
    }
}

@end
