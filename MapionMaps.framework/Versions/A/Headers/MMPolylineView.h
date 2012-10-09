//
//  MMPathView.h
//  MapionMaps
//
//  Created by honjo on 12/05/31.
//  Copyright (c) 2012 Mapion Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>

@class MMMapView;

@interface MMPolylineView : UIView

@property (nonatomic, assign) float lineWidth;
@property (nonatomic, assign) CGLineCap lineCap;
@property (nonatomic, assign) CGLineJoin lineJoin;
@property (nonatomic, assign) CGPathDrawingMode drawingMode;
@property (nonatomic, retain) UIColor *color;

- (id)initWithMapView:(MMMapView *)mapView;
- (void)calculate;
- (void)addCoordinate:(CLLocationCoordinate2D)coordinate;
- (void)addCoordinate:(CLLocationCoordinate2D)coordinate doDraw:(BOOL)doDraw;
- (void)addPoint:(CGPoint)point;
- (void)initialize;

@end
