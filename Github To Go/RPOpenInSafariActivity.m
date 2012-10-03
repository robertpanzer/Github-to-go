//
//  RPOpenInSafariActivity.m
//  Hub To Go
//
//  Created by Robert Panzer on 30.09.12.
//
//

#import "RPOpenInSafariActivity.h"

@implementation RPOpenInSafariActivity

-(NSString*)activityTitle {
    return NSLocalizedString(@"Open in Safari", @"Open in Safari Activity");
}

-(NSString *)activityType {
    return @"OpenInSafari";
}

-(UIImage *)activityImage {
    return [UIImage imageNamed:@"openinsafari"];
}

-(BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    if (activityItems.count == 1) {
        if ([activityItems[0] isKindOfClass:[NSString class]]) {
            NSString *url = activityItems[0];
            return [url hasPrefix:@"http://"] || [url hasPrefix:@"https://"];
        }
    }
    return NO;
}

-(void)prepareWithActivityItems:(NSArray *)activityItems {
    self.url = activityItems[0];
}

-(void)performActivity {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.url]];
    [self activityDidFinish:YES];
}

@end
