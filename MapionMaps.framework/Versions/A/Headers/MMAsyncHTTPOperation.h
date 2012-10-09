//
//  MMAsyncHTTPOperation.h
//  MapionMaps
//
//  Created by honjo on 12/08/01.
//  Copyright (c) 2012 Mapion Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CompleteBlock)(NSData *);

@interface MMAsyncHTTPOperation : NSOperation

@property (nonatomic, retain) NSURLRequest *request;
@property (nonatomic, copy) CompleteBlock callback;

- (void)initialize;

@end
