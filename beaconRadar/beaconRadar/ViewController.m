//
//  ViewController.m
//  beaconRadar
//
//  Created by Nikko Gladkko on 12.08.15.
//  Copyright (c) 2015 TNADZOR. All rights reserved.
//

#import "ViewController.h"
#import "AplicationDefaults.h"
#import "CoreAPI.h"


@import CoreLocation;

@interface ViewController () <CLLocationManagerDelegate>
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSNumberFormatter *numberFormatter;

@property BOOL enabled;
@property NSUUID *uuid;
@property NSNumber *major;
@property NSNumber *minor;
@property BOOL notifyOnEntry;
@property BOOL notifyOnExit;
@property BOOL notifyOnDisplay;

@property (nonatomic, weak) IBOutlet UISwitch *enabledSwitch;
@property (nonatomic, weak) IBOutlet UITextField *uuidTextField;
@property (nonatomic, weak) IBOutlet UITextField *majorTextField;
@property (nonatomic, weak) IBOutlet UITextField *minorTextField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    self.numberFormatter = [[NSNumberFormatter alloc] init];
    self.numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:[AplicationDefaults sharedDefaults].defaultProximityUUID identifier:BeaconIdentifier]; //[NSUUID UUID]
    region = [self.locationManager.monitoredRegions member:region];
    if(region)
    {
        self.view.backgroundColor = [UIColor whiteColor];
        self.enabled = YES;
        self.uuid = region.proximityUUID;
        self.major = region.major;
        self.majorTextField.text = [self.major stringValue];
        self.minor = region.minor;
        self.minorTextField.text = [self.minor stringValue];
        self.notifyOnEntry = region.notifyOnEntry;
        self.notifyOnExit = region.notifyOnExit;
        self.notifyOnDisplay = region.notifyEntryStateOnDisplay;
    }
    else
    {
        self.view.backgroundColor = [UIColor grayColor];
        // Default settings.
        self.enabled = NO;
        
        self.uuid = [AplicationDefaults sharedDefaults].defaultProximityUUID;
        self.major = self.minor = nil;
        self.notifyOnEntry = self.notifyOnExit = YES;
        self.notifyOnDisplay = NO;
    }
    

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self updateMonitoredRegion];
}

- (void)updateMonitoredRegion
{
    self.enabled = YES;
    // if region monitoring is enabled, update the region being monitored
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:[AplicationDefaults sharedDefaults].defaultProximityUUID  identifier:BeaconIdentifier];
    
    if(region != nil)
    {
        [self.locationManager stopMonitoringForRegion:region];
    }
    
    if(self.enabled)
    {
        region = nil;
        if(self.uuid && self.major && self.minor)
        {
            region = [[CLBeaconRegion alloc] initWithProximityUUID:self.uuid major:[self.major shortValue] minor:[self.minor shortValue] identifier:BeaconIdentifier];
        }
        else if(self.uuid && self.major)
        {
            region = [[CLBeaconRegion alloc] initWithProximityUUID:self.uuid major:[self.major shortValue]  identifier:BeaconIdentifier];
        }
        else if(self.uuid)
        {
            region = [[CLBeaconRegion alloc] initWithProximityUUID:self.uuid identifier:BeaconIdentifier];
        }
        
        if(region)
        {
            region.notifyOnEntry = self.notifyOnEntry;
            region.notifyOnExit = self.notifyOnExit;
            region.notifyEntryStateOnDisplay = self.notifyOnDisplay;
            
            [self.locationManager startMonitoringForRegion:region];
        }
    }
    else
    {
        CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:[NSUUID UUID] identifier:BeaconIdentifier];
        [self.locationManager stopMonitoringForRegion:region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region{
    NSLog(@"Start monitoring region with id: %@.",region.identifier);
    [manager requestStateForRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLBeaconRegion *)region
{
    /*
     A user can transition in or out of a region while the application is not running. When this happens CoreLocation will launch the application momentarily, call this delegate method and we will let the user know via a local notification.
     */
    if ([region isKindOfClass:CLBeaconRegion.class]) {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        
        
        if(state == CLRegionStateInside){
            Offers *offer = [self offerForAssetUuid:region.proximityUUID.UUIDString];
            [self performSelectorOnMainThread:@selector(insideTheBeaconRegionWithOffer:) withObject:offer waitUntilDone:NO];
            notification.alertTitle = offer.offerHeader;
            notification.alertBody = offer.offerBoby;
        } else if(state == CLRegionStateOutside){
            [self performSelectorOnMainThread:@selector(outsideTheBeaconRegion) withObject:self waitUntilDone:NO];
            notification.alertBody = NSLocalizedString(@"You're outside the region", @"");
        } else {
            return;
        }
        //[[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }
}

- (void)insideTheBeaconRegionWithOffer:(Offers *)offer{
    self.view.backgroundColor = [UIColor blackColor];
    self.offerImageView.image = [UIImage imageWithData:offer.offerImageData];
}

- (void)outsideTheBeaconRegion{
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    self.offerImageView.image = nil;
    // Dispose of any resources that can be recreated.
}

- (Offers *)offerForAssetUuid:(NSString *)assetUuid{
    Assets *asset;
    Offers *offer;
    NSError *error;
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Assets" inManagedObjectContext:delegate.managedObjectContext];
    fetchRequest.entity = entity;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"assetUuid==%@",assetUuid];
    NSArray *fetchedObjects = [delegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects.count > 0) {
        asset = [fetchedObjects objectAtSafetyIndex:0];
        NSFetchRequest *offerFetchRequest = [NSFetchRequest new];
        NSEntityDescription *offerEntity = [NSEntityDescription entityForName:@"Offers" inManagedObjectContext:delegate.managedObjectContext];
        offerFetchRequest.entity = offerEntity;
        offerFetchRequest.predicate = [NSPredicate predicateWithFormat:@"offerId==%@",asset.offerId];
        NSArray *offerFetchedObjects = [delegate.managedObjectContext executeFetchRequest:offerFetchRequest error:&error];
        offer = [offerFetchedObjects objectAtSafetyIndex:0];
    }
    return offer;
}

- (IBAction)fetchAsset:(id)sender {
    
}
@end
