//
//  CommitQueue.h
//  Github To Go
//
//  Created by Robert Panzer on 07.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StringQueueListElement : NSObject {
    NSString* value;
    StringQueueListElement* nextElement;
}

@property(strong, readonly) NSString* value;
@property(strong) StringQueueListElement* nextElement;

- (id)initWithValue:(NSString*)aValue;
@end

@interface StringQueue : NSObject {
    StringQueueListElement* firstElement;
    StringQueueListElement* lastElement;
}

-(BOOL)isEmpty;
-(NSString*)dequeueString;
-(void)enqueueString:(NSString*)value;

@end
