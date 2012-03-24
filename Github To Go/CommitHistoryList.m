//
//  CommitHistoryList.m
//  Github To Go
//
//  Created by Robert Panzer on 20.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CommitHistoryList.h"



@implementation CommitHistoryList

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)addCommit:(Commit *)commit {
    [self addObject:commit date:commit.committedDate primaryKey:commit.sha];
}

-(NSArray *)commitsForDay:(NSString *)day {
    return [self objectsForDate:day];
}

-(Commit *)lastCommit {
    NSString* lastDate = self.dates.lastObject;
    NSArray* commitsForLastDate = [self objectsForDate:lastDate];//[commitsForDate objectForKey:lastDate];
    return commitsForLastDate.lastObject;
}

-(Commit *)commitForSha:(NSString *)sha {
    return (Commit*)[self objectForPrimaryKey:sha];
}


-(CommitHistoryList *)commitHistoryListFilteredBySearchString:(NSString *)searchString {
    
    CommitHistoryList* ret = [[CommitHistoryList alloc] init];
    
    for (Commit* commit in self.objectsByPrimaryKey.objectEnumerator) {
        if ([commit matchesString:searchString]) {
            [ret addCommit:commit];
        }
    }
    
    return ret;
    
}


@end
