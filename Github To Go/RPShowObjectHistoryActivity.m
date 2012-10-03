//
//  RPShowObjectHistoryActivity.m
//  Hub To Go
//
//  Created by Robert Panzer on 03.10.12.
//
//

#import "RPShowObjectHistoryActivity.h"
#import "BranchViewController.h"

@implementation RPShowObjectHistoryActivity

- (id)initWithCommitSha:(NSString*)commitSha
             repository:(Repository*)repository
            absolutePath:(NSString*)absolutePath
    owningViewController:(UIViewController*)owningViewController
{
    self = [super init];
    if (self) {
        _commitSha = commitSha;
        _repository = repository;
        _absolutePath = absolutePath;
        _owningViewController = owningViewController;
    }
    return self;
}

-(BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

-(UIImage *)activityImage {
    return [UIImage imageNamed:@"history"];
}

-(NSString *)activityTitle {
    return NSLocalizedString(@"Show History", @"Show history activity");
}

-(NSString *)activityType {
    return @"Show History";
}

-(void)performActivity {
    BranchViewController* branchViewController = [[BranchViewController alloc] initWithAbsolutePath:self.absolutePath
                                                                                          commitSha:self.commitSha
                                                                                         repository:self.repository];
    [self.owningViewController.navigationController pushViewController:branchViewController animated:YES];
    [self activityDidFinish:YES];
}

@end
