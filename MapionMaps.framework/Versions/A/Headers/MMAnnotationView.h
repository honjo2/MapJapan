//
//  MMAnnotationView.h
//  MapionMaps
//
//  Created by honjo on 12/05/16.
//  Copyright (c) 2012 Mapion Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class MMMapView;
@class MMPopupView;

@interface MMAnnotationView : UIImageView

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) MMPopupView *popupView;
@property (nonatomic, assign) CGPoint centerOffset;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate mapView:(MMMapView *)mapView;
- (void)onClick;
- (void)onClose;
- (void)reCalculate;
- (void)setCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated;

@end
