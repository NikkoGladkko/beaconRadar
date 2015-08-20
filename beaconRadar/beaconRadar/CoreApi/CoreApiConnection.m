//
//  CoreApiConnection.m
//  beaconRadar
//
//  Created by iOS Developer on 20.08.15.
//  Copyright (c) 2015 TNADZOR. All rights reserved.
//

#import "CoreApiConnection.h"

@implementation CoreApiConnection


- (instancetype) initWithRequest:(NSURLRequest *)request delegate:(id)delegate{
    self = [super initWithRequest:request delegate:delegate];
    if (self){
        self.responseData = [[NSMutableData alloc] init];
    }
    return self;
}

@end
