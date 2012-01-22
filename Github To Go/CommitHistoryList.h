//
//  CommitHistoryList.h
//  Github To Go
//
//  Created by Robert Panzer on 20.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Commit.h"

@interface CommitHistoryList : NSObject {

@private
    NSMutableArray* dates;
    
    NSMutableDictionary* commitsForDate;
    
    NSMutableDictionary* commitBySha;
}

@property(strong, readonly) NSArray* dates; 

@property(readonly) NSInteger count;

- (id)init;

- (void)addCommit:(Commit*)commit;

- (NSArray*) commitsForDay:(NSString*)day;

- (Commit*) lastCommit;

- (Commit*) commitForSha:(NSString*)sha;

@end
