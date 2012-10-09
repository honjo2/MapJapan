//
//  MyCLQuery.m
//  MapionHD
//
//  Created by honjo on 12/06/16.
//  Copyright (c) 2012 mapion. All rights reserved.
//

#import "MyCLQuery.h"

@implementation MyCLQuery

- (id)initWithDelegate:(id <CLLocationManagerDelegate>)delegate {
  if (!(self = [super init])) return nil;
  
  delegate_ = [delegate retain];
  
  return self;
}

- (void)startQuery {
  manager_ = [[CLLocationManager alloc] init];
  manager_.delegate = self;
  
  manager_.desiredAccuracy = kCLLocationAccuracyBest;
  manager_.distanceFilter = kCLDistanceFilterNone;
  
  [manager_ startUpdatingLocation];
}

- (void)stopQuery {
  [manager_ stopUpdatingLocation];
  [manager_ release];
}

- (void)dealloc {
  [self stopQuery]; manager_ = nil;
  [delegate_ release]; delegate_ = nil;
  [super dealloc];
}

#pragma mark - CLLocationManagerDelegate Methods

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
  [delegate_ locationManager:manager didUpdateToLocation:newLocation fromLocation:oldLocation];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
  [delegate_ locationManager:manager didFailWithError:error];
}

@end
