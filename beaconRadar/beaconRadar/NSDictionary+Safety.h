//
//  NSDictionary+Safety.h
//  monitor
//
//  Created by iOS Developer on 09.06.15.
//  Copyright (c) 2015 Ruslink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Safety)
- (id)valueForSafetyKey:(NSString *)key;

- (id)objectForSafetyKey:(id)aKey;
@end
