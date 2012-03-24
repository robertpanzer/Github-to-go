//
//  CommitFile.m
//  Github To Go
//
//  Created by Robert Panzer on 14.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CommitFile.h"

@implementation CommitFile 

@synthesize status;
@synthesize patch;
@synthesize blobUrl;
@synthesize fileName;
@synthesize commit;
@synthesize blobSha;
@synthesize additions;
@synthesize deletions;
@synthesize changes;
@synthesize rawUrl;
@synthesize linesOfOldFile;
@synthesize linesOfNewFile;
@synthesize largestOldLineNo;
@synthesize largestNewLineNo;

- (id)initWithJSONObject:(NSDictionary*)jsonObject commit:(Commit *)aCommit{
    self = [super init];
    if (self) {
        self.commit = aCommit;
        self.status = [jsonObject objectForKey:@"status"];
        self.patch = [jsonObject objectForKey:@"patch"];
        self.blobUrl = [jsonObject objectForKey:@"blob_url"];
        self.rawUrl = [jsonObject objectForKey:@"raw_url"];
        self.fileName = [jsonObject objectForKey:@"filename"];
        self.blobSha = [jsonObject objectForKey:@"sha"];
        self.additions = [(NSNumber*)[jsonObject objectForKey:@"additions"] intValue];
        self.deletions = [(NSNumber*)[jsonObject objectForKey:@"deletions"] intValue];
        self.changes = [(NSNumber*)[jsonObject objectForKey:@"changes"] intValue];
        
        self.linesOfNewFile = [NSMutableDictionary dictionary];
        self.linesOfOldFile = [NSMutableDictionary dictionary];
        
        @try {
            NSArray* lines = [self.patch componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
            int oldLineCounter = 0;
            int newLineCounter = 0;
            for (int i = 0; i <lines.count; i++) {
                NSString* line = [lines objectAtIndex:i];
                
                if ([line hasPrefix:@"@@"]) {
                    NSString* lineInfos = [[[line componentsSeparatedByString:@"@@"] objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    NSArray* oldAndNewLineInfo = [lineInfos componentsSeparatedByString:@" "];
                    NSString* oldLineInfo = [oldAndNewLineInfo objectAtIndex:0];
                    NSString* newLineInfo = [oldAndNewLineInfo objectAtIndex:1];
                    oldLineCounter = [[[[oldLineInfo substringFromIndex:1] componentsSeparatedByString:@","] objectAtIndex:0] intValue];
                    newLineCounter = [[[[newLineInfo substringFromIndex:1] componentsSeparatedByString:@","] objectAtIndex:0] intValue];
                } else if ([line hasPrefix:@"+"]) {
                    NSNumber* lineNo = [NSNumber numberWithInt:newLineCounter];
                    [linesOfNewFile setObject:[line substringFromIndex:1] 
                                 forKey:lineNo];
                    largestNewLineNo = newLineCounter;
                    newLineCounter++;
                } else if ([line hasPrefix:@"-"]) {
                    NSNumber* lineNo = [NSNumber numberWithInt:oldLineCounter];
                    [linesOfOldFile setObject:[line substringFromIndex:1] 
                                 forKey:lineNo];
                    largestOldLineNo = oldLineCounter;
                    oldLineCounter++;
                } else if ([line hasPrefix:@" "]){
                    oldLineCounter++;
                    newLineCounter++;
                }
                
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Error %@", exception);
            for (NSString* st in exception.callStackSymbols) {
                NSLog(@"%@", st);
            }
        }
        NSLog(@"Old Lines:\n%@", linesOfOldFile);
        NSLog(@"New Lines:\n%@", linesOfNewFile);
    }
    return self;
}


@end
