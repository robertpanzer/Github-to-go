//
//  CommitQueue.m
//  Github To Go
//
//  Created by Robert Panzer on 07.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StringQueue.h"

@implementation StringQueueListElement

@synthesize value;
@synthesize nextElement;

- (id)initWithValue:(NSString*)aValue {
    self = [super init];
    if (self) {
        value = aValue;
    }
    return self;
}

@end

@implementation StringQueue

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (BOOL)isEmpty {
    if (firstElement == nil) {
        return YES;
    } else {
        return NO;
    }
}

- (void)enqueueString:(NSString *)value {
    if ([self isEmpty]) {
        firstElement = [[StringQueueListElement alloc] initWithValue:value];
        lastElement = firstElement;
    } else {
        lastElement.nextElement = [[StringQueueListElement alloc] initWithValue:value];
        lastElement = lastElement.nextElement;
    }
}

- (NSString *)dequeueString {
    NSString* value = firstElement.value;
    StringQueueListElement* newFirstElement = firstElement.nextElement;
    firstElement = newFirstElement;
    return value;
}


@end
