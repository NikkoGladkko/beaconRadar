//
//  ViewController.m
//  beaconRadar
//
//  Created by Nikko Gladkko on 12.08.15.
//  Copyright (c) 2015 TNADZOR. All rights reserved.
//

#import "ViewController.h"
@import CoreLocation;

@interface ViewController () <CLLocationManagerDelegate>
@property (nonatomic) CLLocationManager *locationManager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
