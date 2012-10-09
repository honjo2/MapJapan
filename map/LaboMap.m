//
//  LaboMap.m
//  MapionHD
//
//  Created by honjo on 12/07/31.
//  Copyright (c) 2012 mapion. All rights reserved.
//

#import "LaboMap.h"

@implementation LaboMap

- (id)init {
	if (!(self = [super init])) return nil;
  
  self.maxZoom = 19;
  
	return self;
}

@end
