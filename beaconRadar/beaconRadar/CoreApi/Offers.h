//
//  Offers.h
//  beaconRadar
//
//  Created by iOS Developer on 20.08.15.
//  Copyright (c) 2015 TNADZOR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Assets;

@interface Offers : NSManagedObject

@property (nonatomic, retain) NSNumber * offerId;
@property (nonatomic, retain) NSString * offerHeader;
@property (nonatomic, retain) NSString * offerBoby;
@property (nonatomic, retain) NSString * offerImageName;
@property (nonatomic, retain) NSData * offerImageData;
@property (nonatomic, retain) NSSet *assets;
@end

@interface Offers (CoreDataGeneratedAccessors)

- (void)addAssetsObject:(Assets *)value;
- (void)removeAssetsObject:(Assets *)value;
- (void)addAssets:(NSSet *)values;
- (void)removeAssets:(NSSet *)values;

@end
