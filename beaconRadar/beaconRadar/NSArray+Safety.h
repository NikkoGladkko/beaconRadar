//
//  NSArray+Safety.h
//  NAVIXY Viewer
//
//  Created by iOS Developer on 14.05.15.
//  Copyright (c) 2015 Tmh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Safety)
-(id)objectAtSafetyIndex:(NSUInteger)index;
@end
