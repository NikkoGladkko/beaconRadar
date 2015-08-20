//
//  NSArray+Safety.m
//  NAVIXY Viewer
//
//  Created by iOS Developer on 14.05.15.
//  Copyright (c) 2015 Tmh. All rights reserved.
//

#import "NSArray+Safety.h"

@implementation NSArray (Safety)
-(id)objectAtSafetyIndex:(NSUInteger)index{
    id object = nil;
    if (self.count > index){
        object = [self objectAtIndex:index];
    } else {
        object = self.count > 0 ? [self firstObject] : nil;
    }
    return object;
}
@end
