//
//  MMMapView.h
//  MapionMaps
//
//  Created by honjo on 12/05/08.
//  Copyright (c) 2012 Mapion Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMMap.h"

@class MMMapView;
@class MMAnnotationView;

@protocol MMMapViewDelegate <NSObject>

@optional

- (void)beforeMapMove:(MMMapView *)mapView;
- (void)afterMapMove:(MMMapView *)mapView;

- (void)beforeMapZoom:(MMMapView *)mapView;
- (void)afterMapZoom:(MMMapView *)mapView;

- (void)doubleTap:(MMMapView *)mapView point:(CGPoint)point;
- (void)singleTap:(MMMapView *)mapView point:(CGPoint)point;
- (void)singleTapTwoFingers:(MMMapView *)mapView point:(CGPoint)point;
- (void)longSingleTap:(MMMapView *)mapView point:(CGPoint)point;

- (void)tapOnPopup:(MMMapView *)mapView annotationView:(MMAnnotationView *)annotationView control:(UIControl *)control;

- (void)zoomIn:(MMMapView *)mapView point:(CGPoint)point;
- (void)zoomOut:(MMMapView *)mapView point:(CGPoint)point;

- (NSUInteger)cacheCapacity;

@end

@interface MMMapView : UIView

@property (nonatomic, readonly) float screenScale;
@property (nonatomic, assign) double metersPerPixel;
@property (nonatomic, retain) id <MMMap> map;
@property (nonatomic, assign) float zoom;
@property (nonatomic, assign) id <MMMapViewDelegate>delegate;
@property (nonatomic, assign) CLLocationCoordinate2D centerCoordinate;
@property (nonatomic, assign) MMProjectedPoint centerProjectedPoint;
@property (nonatomic, retain) MMAnnotationView *openAnnotation;

- (id)initWithFrame:(CGRect)frame key:(NSString *)key;
- (id)initWithFrame:(CGRect)frame key:(NSString *)key map:(id <MMMap>)map;

- (void)setCenterCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated;
- (void)setCenterProjectedPoint:(MMProjectedPoint)point animated:(BOOL)animated;

- (MMProjectedPoint)pixelToProjectedPoint:(CGPoint)pixelCoordinate;
- (MMProjectedPoint)coordinateToProjectedPoint:(CLLocationCoordinate2D)coordinate;
- (CGPoint)coordinateToAbsolutePixel:(CLLocationCoordinate2D)coordinate;
- (CGPoint)projectedPointToAbsolutePixel:(MMProjectedPoint)projectedPoint;
- (CLLocationCoordinate2D)pixelToCoordinate:(CGPoint)pixelCoordinate;
- (CGPoint)projectedPointToPixel:(MMProjectedPoint)projectedPoint;

- (NSArray *)annotations;
- (void)addAnnotation:(MMAnnotationView *)annotation;
- (void)addAnnotation:(MMAnnotationView *)annotation animated:(BOOL)animated;
- (void)addAnnotations:(NSArray *)annotations;
- (void)addAnnotations:(NSArray *)annotations animated:(BOOL)animated;
- (void)removeAnnotation:(MMAnnotationView *)annotation;
- (void)removeAnnotations:(NSArray *)annotations;

- (void)zoomTo:(float)zoomFactor point:(CGPoint)point;
- (BOOL)containPoint:(CGPoint)point;

-(void)removeAllCache;

@end
