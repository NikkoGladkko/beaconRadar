//
//  Assets.h
//  beaconRadar
//
//  Created by iOS Developer on 20.08.15.
//  Copyright (c) 2015 TNADZOR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Offers;

@interface Assets : NSManagedObject

@property (nonatomic, retain) NSNumber * assetId;
@property (nonatomic, retain) NSString * assetUuid;
@property (nonatomic, retain) NSString * assetName;
@property (nonatomic, retain) NSNumber * offerId;
@property (nonatomic, retain) Offers *offer;

@end
