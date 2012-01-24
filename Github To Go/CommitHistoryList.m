//
//  CommitHistoryList.m
//  Github To Go
//
//  Created by Robert Panzer on 20.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CommitHistoryList.h"

@implementation CommitHistoryList

@synthesize dates;

- (id)init {
    self = [super init];
    if (self) {
        dates = [[NSMutableArray alloc] init];
        commitsForDate = [[NSMutableDictionary alloc] init];
        commitBySha = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)addCommit:(Commit *)commit {
    if ([commitBySha objectForKey:commit.sha] != nil) {
        return;
    }
    [commitBySha setObject:commit forKey:commit.sha];
    NSString* date = [commit.committedDate substringToIndex:10];
    NSMutableArray* commitsForDay = [commitsForDate objectForKey:date];
    if (commitsForDay == nil) {
        BOOL inserted = NO;
        for (int i = 0; i < dates.count; i++) {
            NSString* listDate = [dates objectAtIndex:i];
            if ([listDate compare:date] == NSOrderedAscending) {
                [dates insertObject:date atIndex:i];
                inserted = YES;
                break;
            }
        }
        if (!inserted) {
            [dates addObject:date];
        }
        commitsForDay = [[[NSMutableArray alloc] init] autorelease];
        [commitsForDate setObject:commitsForDay forKey:date];
    }
    [commitsForDay addObject:commit];
}

-(NSArray *)commitsForDay:(NSString *)day {
    NSArray* commitsForDay = [commitsForDate objectForKey:day];
    return commitsForDay;
}

-(Commit *)lastCommit {
    NSString* lastDate = dates.lastObject;
    NSArray* commitsForLastDate = [commitsForDate objectForKey:lastDate];
    return commitsForLastDate.lastObject;
}

-(Commit *)commitForSha:(NSString *)sha {
    return [commitBySha objectForKey:sha];
}

- (NSInteger)count {
    return commitBySha.count;
}

-(CommitHistoryList *)commitHistoryListFilteredBySearchString:(NSString *)searchString {
    
    CommitHistoryList* ret = [[[CommitHistoryList alloc] init] autorelease];
    
    for (Commit* commit in commitBySha.objectEnumerator) {
        if ([commit matchesString:searchString]) {
            [ret addCommit:commit];
        }
    }
    
    return ret;
    
}

- (void)dealloc {
    [dates release];
    [commitsForDate release];
    [commitBySha release];
    [super dealloc];
}

@end
