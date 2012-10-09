//
//  SearchDetailTableViewController.m
//  map
//
//  Created by honjo2 on 2012/09/30.
//  Copyright (c) 2012年 honjo2. All rights reserved.
//

#import "SearchDetailTableViewController.h"

@implementation SearchDetailTableViewController

@synthesize feature = feature_;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
  [feature_ release], feature_ = nil;
  [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  // ナビゲーションバー表示
  [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - Table view data source

// セクションの数を返す
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

// セクション毎のcell数を返す
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == 0) {
    return 3;
  } else {
    return 3;
  }
}

// セルの中身を作る
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  switch (indexPath.section) {
    case 0: {
      static NSString *kTextCellID = @"TextCell";
      UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTextCellID];
      if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:kTextCellID] autorelease];
      }
      cell.detailTextLabel.numberOfLines = 0;
  
      NSString *name = [self.feature objectForKey:@"Name"];
      NSDictionary *property = [self.feature objectForKey:@"Property"];
      NSString *address = [property objectForKey:@"Address"];
      NSString *tel1 = [property objectForKey:@"Tel1"];
  
      switch (indexPath.row) {
        case 0: {
          cell.selectionStyle = UITableViewCellSelectionStyleNone;
          cell.textLabel.text = @"名称";
          cell.detailTextLabel.text = name;
          break;
        }
        case 1: {
          cell.selectionStyle = UITableViewCellSelectionStyleNone;
          cell.textLabel.text = @"住所";
          cell.detailTextLabel.text = address;
          break;
        }
        case 2: {
          cell.textLabel.text = @"電話番号";
          cell.detailTextLabel.text = tel1;
          cell.detailTextLabel.textColor = [UIColor blueColor];
          break;
        }
        default:
          break;
      }
      return cell;
    }
    case 1: {
      static NSString *kTextCellID = @"TextCellShare";
      UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTextCellID];
      if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTextCellID] autorelease];
      }
      cell.textLabel.numberOfLines = 0;
      cell.textLabel.textColor = [UIColor blueColor];
      cell.textLabel.textAlignment = NSTextAlignmentCenter;
      
      switch (indexPath.row) {
        case 0: {
          cell.textLabel.text = @"Twitter";
          break;
        }
        case 1: {
          cell.textLabel.text = @"Facebook";
          break;
        }
        case 2: {
          cell.textLabel.text = @"メール";
          break;
        }
        default: break;
      }
      return cell;
    }
    default: break;
  }
  
return nil;
}

// ヘッダ
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  if (section == 1) return @"共有";
  return nil;
} 

#pragma mark - Table view delegate

// セルタップ時の挙動
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  switch (indexPath.section) {
    case 0: {
      if (indexPath.row == 2) {
        NSDictionary *property = [self.feature objectForKey:@"Property"];
        NSString *tel1 = [property objectForKey:@"Tel1"];
        NSString *callTel = [NSString stringWithFormat:@"tel://%@", tel1];
        NSURL *phone = [NSURL URLWithString:callTel];
        [[UIApplication sharedApplication] openURL:phone];
      }
      break;
    }
    case 1: {
      NSString *name = [self.feature objectForKey:@"Name"];
      NSDictionary *geometryDic = [self.feature objectForKey:@"Geometry"];
      NSString *coordinates = [geometryDic objectForKey:@"Coordinates"];
      NSArray *coordinateArray = [coordinates componentsSeparatedByString:@","];
      NSString *latitude = [coordinateArray objectAtIndex:1];
      NSString *longitude = [coordinateArray objectAtIndex:0];
      NSString *googleMapURLStr = [[NSString stringWithFormat:@"http://maps.google.co.jp/maps?ll=%@,%@&q=%@", latitude, longitude, name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//      NSLog(@"url=%@", googleMapURLStr);
      NSURL *googleMapURL = [NSURL URLWithString:googleMapURLStr];
      
      switch (indexPath.row) {
        case 0: {
          SLComposeViewController *twitterPostVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
          [twitterPostVC setInitialText:name];
          [twitterPostVC addURL:googleMapURL];
          [self presentViewController:twitterPostVC animated:YES completion:nil];

          break;
        }
        case 1: {
          SLComposeViewController *facebookPostVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
          [facebookPostVC setInitialText:name];
          [facebookPostVC addURL:googleMapURL];
          [self presentViewController:facebookPostVC animated:YES completion:nil];

          break;
        }
        case 2: {
          if (![MFMailComposeViewController canSendMail]) {
            UIAlertView* alert=[[[UIAlertView alloc]
                                 initWithTitle:@"" message:@"メール送信できません。" delegate:nil
                                 cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
            [alert show];
            return;
          }
          MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
          
          picker.mailComposeDelegate = self;
          [picker setSubject:name];
          [picker setMessageBody:googleMapURLStr isHTML:NO];
          
          [self presentViewController:picker animated:YES completion:nil];
          [picker release];
          break;
        }
        default:
          break;
      }
      break;
    }
    default: break;
  }
  
}

#pragma mark - MFMailComplseViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
  switch (result) {
    case MFMailComposeResultSent:
      //送信完了
      break;
    case MFMailComposeResultSaved:
      //下書き保存
      break;
    case MFMailComposeResultCancelled:
      //キャンセル
      break;
    case MFMailComposeResultFailed:
      //失敗
      break;
  }
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
