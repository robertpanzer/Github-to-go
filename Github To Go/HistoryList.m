//
//  HistoryList.m
//  Github To Go
//
//  Created by Robert Panzer on 12.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HistoryList.h"

@implementation HistoryList 

@synthesize dates;
@synthesize objectsForDate;
@synthesize objectsByPrimaryKey;

- (id)init {
    self = [super init];
    if (self) {
        self.dates = [NSMutableArray array];
        self.objectsForDate = [NSMutableDictionary dictionary];
        self.objectsByPrimaryKey = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void)addObject:(NSObject *)anObject date:(NSString *)aDate primaryKey:(NSString *)aPrimaryKey {
    
    if (aPrimaryKey != nil && [self.objectsByPrimaryKey objectForKey:aPrimaryKey] != nil) {
        return;
    }
    
    NSString* date = [aDate substringToIndex:10];
    
    if (aPrimaryKey != nil) {
        [objectsByPrimaryKey setObject:anObject forKey:aPrimaryKey];
    }
    NSMutableArray* objectsForDay = [self.objectsForDate objectForKey:date];
    if (objectsForDay == nil) {
        BOOL inserted = NO;
        for (int i = 0; i < self.dates.count; i++) {
            NSString* listDate = [self.dates objectAtIndex:i];
            if ([listDate compare:date] == NSOrderedAscending) {
                [dates insertObject:date atIndex:i];
                inserted = YES;
                break;
            }
        }
        if (!inserted) {
            [dates addObject:date];
        }
        objectsForDay = [NSMutableArray array];
        [self.objectsForDate setObject:objectsForDay forKey:date];
    }
    [objectsForDay addObject:anObject];
    
    count++;
    
}


-(NSArray *)objectsForDate:(NSString *)aDate {
    return [objectsForDate objectForKey:aDate];
}

-(NSObject *)objectForPrimaryKey:(NSString *)primaryKey {
    return [self.objectsByPrimaryKey objectForKey:primaryKey];
}

- (NSInteger)count {
    return count;
}



@end
