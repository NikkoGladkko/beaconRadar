//
//  OfferWr.h
//  beaconRadar
//
//  Created by iOS Developer on 21.08.15.
//  Copyright (c) 2015 TNADZOR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OfferWr : NSObject
@property (nonatomic, strong) NSNumber * offerId;
@property (nonatomic, strong) NSString * offerHeader;
@property (nonatomic, strong) NSString * offerBoby;
@property (nonatomic, retain) NSData * offerImageData;
@end
