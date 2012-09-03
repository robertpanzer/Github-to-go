//
//  NSDictionary+RPJSONObjectAccess.m
//  Hub To Go
//
//  Created by Robert Panzer on 03.09.12.
//
//

#import "NSDictionary+RPJSONObjectAccess.h"

@implementation NSDictionary (RPJSONObjectAccess)

-(id)jsonObjectForKey:(id)aKey
{
    id value = [self objectForKey:aKey];
    if (value == [NSNull null]) {
        return nil;
    } else {
        return value;
    }
}

@end
