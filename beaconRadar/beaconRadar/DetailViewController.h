//
//  DetailViewController.h
//  beaconRadar
//
//  Created by iOS Developer on 21.08.15.
//  Copyright (c) 2015 TNADZOR. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *headerText;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UITextView *bodyText;
@property (strong, nonatomic) Offers *offer;

@end
