//
//  MMFoundation.h
//  MapionMaps
//
//  Created by honjo on 12/05/09.
//  Copyright (c) 2012 Mapion Co.,Ltd. All rights reserved.
//

#ifndef MapionMaps_MMFoundation_h
#define MapionMaps_MMFoundation_h

#include <stdint.h>

typedef struct {
	double x, y;
} MMProjectedPoint;

typedef struct {
	double width, height;
} MMProjectedSize;

typedef struct {
	MMProjectedPoint origin;
	MMProjectedSize size;
} MMProjectedRect;

typedef struct {
	uint32_t x, y;
	short zoom;
} MMTile;

MMProjectedPoint MMProjectedPointMake(double x, double y);
MMProjectedRect  MMProjectedRectMake(double x, double y, double width, double height);
MMProjectedSize  MMProjectedSizeMake(double width, double heigth);
MMTile MMTileMake(uint32_t x, uint32_t y, short zoom);
uint64_t MMTileKey(MMTile tile);

#endif
