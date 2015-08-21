//
//  AplicationDefaults.m
//  beaconRadar
//
//  Created by Nikko Gladkko on 12.08.15.
//  Copyright (c) 2015 TNADZOR. All rights reserved.
//

#import "AplicationDefaults.h"

NSString *BeaconIdentifier = @"com.example.beaconRadar";


@implementation AplicationDefaults

- (id)init
{
    self = [super init];
    if(self)
    {
        // uuidgen should be used to generate UUIDs.
        //
        _supportedProximityUUIDs = [[NSArray alloc] init];
        NSError *error;
        AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        NSFetchRequest *fetchRequest = [NSFetchRequest new];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Assets" inManagedObjectContext:delegate.managedObjectContext];
        fetchRequest.entity = entity;
        //fetchRequest.predicate = [NSPredicate predicateWithFormat:@"assetUuid.length>35"];
        NSArray *fetchedObjects = [delegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        for (NSManagedObject *object in fetchedObjects) {
            if ([object isKindOfClass:Assets.class]) {
                Assets *asset = (Assets *)object;
                NSUUID *assetUUID = [[NSUUID alloc] initWithUUIDString:asset.assetUuid];
                if (assetUUID) {
                    _supportedProximityUUIDs = [_supportedProximityUUIDs arrayByAddingObject:assetUUID];
                }
                
            }
        }
        //        _supportedProximityUUIDs = @[[[NSUUID alloc] initWithUUIDString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"],
        //                                     [[NSUUID alloc] initWithUUIDString:@"5A4BCFCE-174E-4BAC-A814-092E77F6B7E5"],
        //                                     [[NSUUID alloc] initWithUUIDString:@"74278BDA-B644-4520-8F0C-720EAF059935"],
        //                                     [[NSUUID alloc] initWithUUIDString:@"8492E75F-4FD6-469D-B132-043FE94921D8"],
//                                             [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"]];
        _defaultPower = @-59;
    }
    
    return self;
}


+ (AplicationDefaults *)sharedDefaults
{
    static id sharedDefaults = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDefaults = [[self alloc] init];
    });
    
    return sharedDefaults;
}


- (NSUUID *)defaultProximityUUID
{
    return _supportedProximityUUIDs[0];
}


@end
