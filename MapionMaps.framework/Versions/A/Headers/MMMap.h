//
//  MMMap.h
//  MapionMaps
//
//  Created by honjo on 12/05/09.
//  Copyright (c) 2012 Mapion Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MMFoundation.h"

@protocol MMMap <NSObject>

- (UIImage *)imageForTile:(MMTile)tile;

- (CLLocationCoordinate2D)projectedPointToCoordinate:(MMProjectedPoint)point;
- (MMProjectedPoint)coordinateToProjectedPoint:(CLLocationCoordinate2D)coordinate;

- (float)minZoom;
- (float)maxZoom;
- (int)tileLength;
- (MMProjectedRect)projectedRect;
- (NSString *)name;
- (NSString *)version;
- (NSString *)copyright;

@optional

- (NSURL *)URLForTile:(MMTile)tile;

@end
