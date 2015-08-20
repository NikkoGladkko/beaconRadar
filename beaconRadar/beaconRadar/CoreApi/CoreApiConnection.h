//
//  CoreApiConnection.h
//  beaconRadar
//
//  Created by iOS Developer on 20.08.15.
//  Copyright (c) 2015 TNADZOR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreAPI.h"


@interface CoreApiConnection : NSURLConnection

@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic) ApiRequestType apiRequestType;

@end
