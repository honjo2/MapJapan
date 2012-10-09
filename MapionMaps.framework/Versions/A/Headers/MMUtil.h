//
//  MMUtil.h
//  MapionMaps
//
//  Created by honjo on 12/05/21.
//  Copyright (c) 2012 Mapion Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MMUtil : NSObject

+ (double)distance:(CLLocationCoordinate2D)coordinate1 loc2:(CLLocationCoordinate2D)coordinate2;
+ (CLLocationCoordinate2D)wgsToTky:(CLLocationCoordinate2D)coordinate;
+ (CLLocationCoordinate2D)tkyToWgs:(CLLocationCoordinate2D)coordinate;
+ (BOOL)isUnder_iPhone4;

@end
