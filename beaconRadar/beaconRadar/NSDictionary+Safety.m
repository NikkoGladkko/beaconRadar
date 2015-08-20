//
//  NSDictionary+Safety.m
//  monitor
//
//  Created by iOS Developer on 09.06.15.
//  Copyright (c) 2015 Ruslink. All rights reserved.
//

#import "NSDictionary+Safety.h"

@implementation NSDictionary (Safety)

- (id)valueForSafetyKey:(NSString *)key{
    id value = nil;
    if ([self.allKeys containsObject:key]) {
        value = [self valueForKey:key];
    }
    return value;
}

- (id)objectForSafetyKey:(id)aKey{
    id value = nil;
    if ([self.allKeys containsObject:aKey]) {
        value = [self objectForKey:aKey];
    }
    return value;
}
@end
