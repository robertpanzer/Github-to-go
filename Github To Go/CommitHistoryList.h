//
//  CommitHistoryList.h
//  Github To Go
//
//  Created by Robert Panzer on 20.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Commit.h"
#import "HistoryList.h"


@interface CommitHistoryList : HistoryList


- (id)init;

- (void)addCommit:(Commit*)commit;

- (NSArray*) commitsForDay:(NSString*)day;

- (Commit*) lastCommit;

- (Commit*) commitForSha:(NSString*)sha;

- (CommitHistoryList*) commitHistoryListFilteredBySearchString:(NSString*)searchString;

@end
