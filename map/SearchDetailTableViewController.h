//
//  SearchDetailTableViewController.h
//  map
//
//  Created by honjo2 on 2012/09/30.
//  Copyright (c) 2012年 honjo2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <MessageUI/MessageUI.h>

@interface SearchDetailTableViewController : UITableViewController <MFMailComposeViewControllerDelegate>

@property (nonatomic, retain) NSDictionary *feature;

@end
