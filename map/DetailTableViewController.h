//
//  DetailTableViewController.h
//  map
//
//  Created by honjo2 on 2012/09/29.
//  Copyright (c) 2012年 honjo2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapionMaps/MapionMaps.h>
#import <Social/Social.h>
#import <MessageUI/MessageUI.h>

@interface DetailTableViewController : UITableViewController <MFMailComposeViewControllerDelegate, UITextFieldDelegate>

@property (nonatomic, retain) MMMapView *mapView;
@property (nonatomic, retain) MMAnnotationView *annotationView;

@end
