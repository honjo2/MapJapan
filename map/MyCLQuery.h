//
//  MyCLQuery.h
//  MapionHD
//
//  Created by honjo on 12/06/16.
//  Copyright (c) 2012 mapion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "ViewController.h"

@interface MyCLQuery : NSObject <CLLocationManagerDelegate> {
@private
  CLLocationManager *manager_;
  id <CLLocationManagerDelegate> delegate_;
}

- (id)initWithDelegate:(id <CLLocationManagerDelegate>)delegate;
- (void)startQuery;
- (void)stopQuery;

@end
