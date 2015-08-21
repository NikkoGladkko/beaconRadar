//
//  MasterTableViewController.m
//  beaconRadar
//
//  Created by iOS Developer on 21.08.15.
//  Copyright (c) 2015 TNADZOR. All rights reserved.
//

#import "MasterTableViewController.h"
#import "DetailViewController.h"
#import "AplicationDefaults.h"
#import "CoreAPI.h"
#import "OfferWr.h"

@import CoreLocation;
@interface MasterTableViewController () <CLLocationManagerDelegate>
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSNumberFormatter *numberFormatter;
@end

@implementation MasterTableViewController{
    NSMutableArray *visibleAssets;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    visibleAssets = [[NSMutableArray alloc] init];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self updateMonitoredRegion];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateMonitoredRegion
{
    // if region monitoring is enabled, update the region being monitored
    NSArray *UUIDArray = [AplicationDefaults sharedDefaults].supportedProximityUUIDs;
    for (NSUUID *proxUUID in UUIDArray) {
        CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:proxUUID  identifier:BeaconIdentifier];
        if(region)
        {
            region.notifyOnEntry = YES;
            region.notifyOnExit = YES;
            region.notifyEntryStateOnDisplay = YES;
            [self.locationManager startMonitoringForRegion:region];
        } else {
            [self.locationManager stopMonitoringForRegion:region];
        }
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
        //UILocalNotification *notification = [[UILocalNotification alloc] init];
        Offers *offer = [self offerForAssetUuid:region.proximityUUID.UUIDString];
        OfferWr *theOffer = [OfferWr new];
        theOffer.offerId = offer.offerId;
        theOffer.offerHeader= offer.offerHeader;
        theOffer.offerBoby = offer.offerBoby;
        theOffer.offerImageData = offer.offerImageData;
        if(state == CLRegionStateInside){
            BOOL exist = NO;
            NSString *str = theOffer.offerHeader;
            NSString *bd = theOffer.offerBoby;

            for (Offers *tOffer in visibleAssets){
                if (tOffer.offerId == theOffer.offerId) {
                    [visibleAssets removeObject:tOffer];
                    [visibleAssets addObject:theOffer];
                    exist = YES;
                }
            }
            if (!exist){
            [visibleAssets addObject:theOffer];
            }
            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            //[[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        } else {
//            if ([visibleAssets containsObject:offer]){
//                [visibleAssets removeObject:offer];
//            }
        }
        
        //        } else if(state == CLRegionStateOutside){
        //            [self performSelectorOnMainThread:@selector(outsideTheBeaconRegion) withObject:self waitUntilDone:NO];
        //            notification.alertBody = NSLocalizedString(@"You're outside the region", @"");
        //        } else {
        //            return;
        //        }
        
    }
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return visibleAssets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detailCell" forIndexPath:indexPath];
    Offers *offer = [visibleAssets objectAtSafetyIndex:indexPath.row];
    cell.imageView.image = [UIImage imageWithData:offer.offerImageData];
    cell.textLabel.text = offer.offerHeader;
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"showDetail" sender:self];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    id destVC = segue.destinationViewController;
    if ([destVC isKindOfClass:DetailViewController.class]){
        DetailViewController *detailVC = destVC;
        NSInteger selectedRow = self.tableView.indexPathForSelectedRow.row;
        Offers *selectedOffer = [visibleAssets objectAtSafetyIndex:selectedRow];
        detailVC.offer = selectedOffer;
        NSString *str = selectedOffer.offerHeader;
        NSString *bd = selectedOffer.offerBoby;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
