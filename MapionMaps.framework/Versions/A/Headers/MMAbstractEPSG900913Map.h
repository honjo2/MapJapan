//
//  MMAbstractEPSG900913Map.h
//  MapionMaps
//
//  Created by honjo on 12/05/09.
//  Copyright (c) 2012 Mapion Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMMap.h"

@interface MMAbstractEPSG900913Map : NSObject <MMMap>

@property (nonatomic, assign) float minZoom;
@property (nonatomic, assign) float maxZoom;
@property (nonatomic, assign) NSUInteger tileLength;
@property (nonatomic, assign) MMProjectedRect projectedRect;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *version;
@property (nonatomic, retain) NSString *copyright;

@end
