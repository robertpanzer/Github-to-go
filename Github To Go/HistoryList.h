//
//  HistoryList.h
//  Github To Go
//
//  Created by Robert Panzer on 12.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HistoryList : NSObject {
    NSMutableArray* dates;
    NSMutableDictionary* objectsForDate;
    NSMutableDictionary* objectsByPrimaryKey;
    NSInteger count;
}

@property(strong) NSMutableArray* dates;
@property(strong) NSMutableDictionary* objectsForDate;
@property(strong) NSMutableDictionary* objectsByPrimaryKey;
@property(readonly, nonatomic) NSInteger count;

-(id) init;

-(NSIndexPath*) addObject:(NSObject*)anObject date:(NSDate*)aDate primaryKey:(NSString*)aPrimaryKey;

-(NSArray*) objectsForDate:(NSString*)aDate;

-(NSObject*) objectForPrimaryKey:(NSString*)primaryKey;

-(id) objectAtIndexPath:(NSIndexPath*)indexPath;

-(NSIndexPath*)indexPathOfObject:(id)object;

-(NSString*)stringFromInternalDate:(NSString*)internalDate;

@end
