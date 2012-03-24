//
//  HistoryList.m
//  Github To Go
//
//  Created by Robert Panzer on 12.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HistoryList.h"

@interface HistoryList()

@property(nonatomic) NSInteger count;

@end

@implementation HistoryList 

@synthesize dates;
@synthesize objectsForDate;
@synthesize objectsByPrimaryKey;
@synthesize count;

- (id)init {
    self = [super init];
    if (self) {
        self.dates = [NSMutableArray array];
        self.objectsForDate = [NSMutableDictionary dictionary];
        self.objectsByPrimaryKey = [NSMutableDictionary dictionary];
    }
    return self;
}

-(NSIndexPath*)addObject:(NSObject *)anObject date:(NSDate*)aDate primaryKey:(NSString *)aPrimaryKey {
    
    if (aPrimaryKey != nil && [self.objectsByPrimaryKey objectForKey:aPrimaryKey] != nil) {
        return nil;
    }
    
    NSUInteger section, row;
    
//    NSString* date = [aDate substringToIndex:10];
//    
    NSDateFormatter *df = nil;
    df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyyMMdd";

    NSString *date = [df stringFromDate:aDate];
    if (aPrimaryKey != nil) {
        [self.objectsByPrimaryKey setObject:anObject forKey:aPrimaryKey];
    }
    NSMutableArray *objectsForDay = [self.objectsForDate objectForKey:date];
    NSMutableArray *timesForDay = [self.objectsForDate objectForKey:[date stringByAppendingString:@"_times"]];
    if (objectsForDay == nil) {
        BOOL inserted = NO;
        for (int i = 0; i < self.dates.count; i++) {
            NSString* listDate = [self.dates objectAtIndex:i];
            if ([listDate compare:date] == NSOrderedAscending) {
                [dates insertObject:date atIndex:i];
                inserted = YES;
                section = i;
                break;
            }
        }
        if (!inserted) {
            section = dates.count;
            [dates addObject:date];
        }
        objectsForDay = [NSMutableArray array];
        [self.objectsForDate setObject:objectsForDay forKey:date];
        timesForDay = [NSMutableArray array];
        [self.objectsForDate setObject:timesForDay forKey:[date stringByAppendingString:@"_times"]];
    } else {
        section = [dates indexOfObject:date];
    }
    
    BOOL inserted = NO;
    for (int i = 0; i < objectsForDay.count; i++) {
        NSDate *time = [timesForDay objectAtIndex:i];
        if ([time earlierDate:aDate] == time) {
            [timesForDay insertObject:aDate atIndex:i];
            [objectsForDay insertObject:anObject atIndex:i];
            inserted = YES;
            row = i;
            break;
        }
    }
    if (!inserted) {
        [timesForDay addObject:aDate];
        row = objectsForDay.count;
        [objectsForDay addObject:anObject];
    }
    
    self.count++;
    return [NSIndexPath indexPathForRow:row inSection:section];
    
}


-(NSArray *)objectsForDate:(NSString *)aDate {
    return [self.objectsForDate objectForKey:aDate];
}

-(NSObject *)objectForPrimaryKey:(NSString *)primaryKey {
    return [self.objectsByPrimaryKey objectForKey:primaryKey];
}


-(NSString*)stringFromInternalDate:(NSString*)internalDate {
    NSDateFormatter *df = nil;
    df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyyMMdd";
    NSDate *date = [df dateFromString:internalDate];
    return [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterNoStyle];
}

-(id) objectAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.section >= self.dates.count) {
        return nil;
    }
    NSString *date = [self.dates objectAtIndex:indexPath.section];
    NSArray *objects = [self objectsForDate:date];
    if (indexPath.row >= objects.count) {
        return nil;
    }
    return [objects objectAtIndex:indexPath.row];
}

-(NSIndexPath*)indexPathOfObject:(id)object {
    for (int section = 0; section < dates.count; section++) {
        NSString *date = [dates objectAtIndex:section];
        NSArray *objects = [self objectsForDate:date];
        for (int row = 0; row < objects.count; row++) {
            id currentObject = [objects objectAtIndex:row];
            if ([object isEqual:currentObject]) {
                return [NSIndexPath indexPathForRow:row inSection:section];
            }
        }
    }
    return nil;
}

@end
