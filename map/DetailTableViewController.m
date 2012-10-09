//
//  DetailTableViewController.m
//  map
//
//  Created by honjo2 on 2012/09/29.
//  Copyright (c) 2012年 honjo2. All rights reserved.
//

#import "DetailTableViewController.h"
#import "ViewController.h"
#import "SBJson.h"
#import "ISTableViewCell.h"

static NSString * const kAltSearch = @"http://alt.search.olp.yahooapis.jp/OpenLocalPlatform/V1/getAltitude?coordinates=%f,%f&output=json&appid=%@";

@implementation DetailTableViewController {
  NSString *_altitude;
  UITextField *_editingTextField;
}

@synthesize mapView = mapView_;
@synthesize annotationView = annotationView_;

- (void)dealloc {
  [_altitude release], _altitude = nil;
  [_editingTextField release], _editingTextField = nil;
  [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
  
  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
  _altitude = @"";
  NSString *urlString = [NSString stringWithFormat:kAltSearch, self.annotationView.coordinate.longitude, self.annotationView.coordinate.latitude, [ViewController yahooAppID]];
  NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
  [NSURLConnection sendAsynchronousRequest:request
                                     queue:[NSOperationQueue mainQueue]
                         completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                           if (error)  return;
                           
                           NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                           id jresult = [result JSONValue];
                           [result release];
                           
                           NSDictionary *dic = (NSDictionary *)jresult;
                           
                           NSArray *featureArray = [dic objectForKey:@"Feature"];
                           NSDictionary *featureDic = [featureArray objectAtIndex:0];
                           NSDictionary *propertyDic = [featureDic objectForKey:@"Property"];
                           _altitude = [propertyDic objectForKey:@"Altitude"];
                           [self.tableView reloadData];
                           [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                         }];
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

// セクション毎のcell数を返す
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  switch (section) {
    case 0:  return 2;
    case 1:  return 2;
    case 2:  return 3;
    default: return 0;
  }
}

// セルの中身を作る
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  switch (indexPath.section) {
    case 0: {
      if (indexPath.row == 0) {
        static NSString *kEditTextCellID = @"EditTextCell";
        ISTableViewCell *cell = (ISTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kEditTextCellID];
        if (cell == nil) {
          cell = [[[ISTableViewCell alloc] initWithStyle:ISTableViewCellEditingStyleValue2 reuseIdentifier:kEditTextCellID] autorelease];
        }
        cell.textColor = [UIColor blueColor];
        cell.textLabel.text = @"名称";
        cell.detailTextField.text = self.annotationView.title;
        cell.detailTextField.delegate = self;
        return cell;
      } else {
        static NSString *kTextCellID = @"TextCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTextCellID];
        if (cell == nil) {
          cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:kTextCellID] autorelease];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.detailTextLabel.numberOfLines = 0;
        cell.textLabel.text = @"標高";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ m", _altitude];
        return cell;
      }
    }
    case 1: {
      static NSString *kButtonCellID = @"ButtonCellForPin";
      UITableViewCell *cell = [tableView
                               dequeueReusableCellWithIdentifier:kButtonCellID];
      if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kButtonCellID] autorelease];
      }
      if (indexPath.row == 0) {
        cell.textLabel.text = @"このピンを削除";
      } else {
        cell.textLabel.text = @"独自ピンを全て削除";
      }
      cell.textLabel.textAlignment = NSTextAlignmentCenter;
      
      return cell;
    }
    case 2: {
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
        }
        default: break;
      }
      return cell;
    }
    default:
      break;
  }
  return nil;
}

// ヘッダ
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  if (section == 2) return @"共有";
  return nil;
}

#pragma mark - Table view delegate

// セルタップ時の挙動
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  switch (indexPath.section) {
    case 0: {

      break;
    }
    case 1: {
      if (indexPath.row == 0) {
        [self.mapView removeAnnotation:self.annotationView];
      } else {
        for (MMAnnotationView *annotationView in self.mapView.annotations) {
          if (annotationView.tag == kSelfPinTag) {
            [self.mapView removeAnnotation:annotationView];
          }
        }
      }
      [self.navigationController popViewControllerAnimated:YES];
      break;
    }
    case 2: {
 
      NSString *googleMapURLStr = [NSString stringWithFormat:@"http://maps.google.co.jp/maps?q=%f,%f", self.annotationView.coordinate.latitude, self.annotationView.coordinate.longitude];
      //      NSLog(@"url=%@", googleMapURLStr);
      NSURL *googleMapURL = [NSURL URLWithString:googleMapURLStr];
      
      switch (indexPath.row) {
        case 0: {
          SLComposeViewController *twitterPostVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
          [twitterPostVC addURL:googleMapURL];
          [self presentViewController:twitterPostVC animated:YES completion:nil];
          
          break;
        }
        case 1: {
          SLComposeViewController *facebookPostVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
          [facebookPostVC addURL:googleMapURL];
          [self presentViewController:facebookPostVC animated:YES completion:nil];
          
          break;
        }
        case 2: {
          MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
          picker.mailComposeDelegate = self;
          [picker setSubject:self.annotationView.title];
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

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
  _editingTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
  self.annotationView.title = textField.text;
  _editingTextField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  self.annotationView.title = textField.text;
  [_editingTextField resignFirstResponder];
  return YES;
}

@end
