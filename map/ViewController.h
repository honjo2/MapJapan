//
//  ViewController.h
//  map
//
//  Created by honjo2 on 2012/09/28.
//  Copyright (c) 2012年 honjo2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapionMaps/MapionMaps.h>

#define kCurrentLocationPinTag 0
#define kSelfPinTag 1
#define kSearchPinTag 2

#define kMaxAnnotationsCount 20

static NSString * const kLastLatitude = @"MapionHD_last_latitude";
static NSString * const kLastLongitude = @"MapionHD_last_longitude";
static NSString * const kLastZoom = @"MapionHD_last_zoom";

static NSString * const kAnnotationAddress = @"MapionHD_address_%d";
static NSString * const kAnnotationLatitude = @"MapionHD_latitude_%d";
static NSString * const kAnnotationLongitude = @"MapionHD_longitude_%d";

@interface ViewController : UIViewController <MMMapViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate>

@property (nonatomic, retain) MMMapView *mapView;

+ (NSString *)yahooAppID;

@end
