//
//  ViewController.m
//  map
//
//  Created by honjo2 on 2012/09/28.
//  Copyright (c) 2012年 honjo2. All rights reserved.
//

#import "ViewController.h"
#import "LaboMap.h"
#import "SBJson.h"
#import "DetailTableViewController.h"
#import "SearchDetailTableViewController.h"
#import "MyAnnotationView.h"
#import "MyCLQuery.h"

// === ここにMapionMaps.frameworkの認証キーとY!のデベロッパIDを入れる ===
static NSString * const kMapionMapsKey = @"input";
static NSString * const kYahooDeveloperID = @"input";
// ================================================================

static NSString * const kReverseGeocoder = @"http://reverse.search.olp.yahooapis.jp/OpenLocalPlatform/V1/reverseGeoCoder?lat=%f&lon=%f&output=json&appid=%@";

static NSString * const kLocalSearch = @"http://search.olp.yahooapis.jp/OpenLocalPlatform/V1/localSearch?lat=%f&lon=%f&dist=10&query=%@&start=0&results=20&sort=dist&output=json&appid=%@";

@implementation ViewController {
  UIButton *_currentLocationBtn;
  UIButton *_searchBtn;
  UIButton *_researchBtn;
  UIButton *_searchClearBtn;
  NSString *_lastSearchText;
  NSArray *_featureArray;
  MMAnnotationView *_currentLocationView;
  MyCLQuery *_locationQuery;
  CLLocationCoordinate2D _lastCoordinate;
  UISearchBar *_searchBar;
}

@synthesize mapView = mapView_;

+ (NSString *)yahooAppID {
  return kYahooDeveloperID;
}

- (void)dealloc {
  [mapView_ release], mapView_ = nil;
  [_currentLocationBtn release], _currentLocationBtn = nil;
  [_searchBtn release], _searchBtn = nil;
  [_researchBtn release], _researchBtn = nil;
  [_searchClearBtn release], _searchClearBtn = nil;
  [_lastSearchText release], _lastSearchText = nil;
  [_featureArray release], _featureArray = nil;
  [_currentLocationView release], _currentLocationView = nil;
  [_locationQuery release]; _locationQuery = nil;
  [_searchBar release], _searchBar = nil;
  [super dealloc];
}

- (void)viewDidLoad {
  [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  
  CGRect mapViewBounds = [self mapViewBounds];
    
  id <MMMap> map = [[LaboMap alloc] init];  
  mapView_ = [[[MMMapView alloc] initWithFrame:mapViewBounds key:kMapionMapsKey map:map] retain];
  [map release];
  
  NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
  [defaults setObject:@"35.658611" forKey:kLastLatitude]; // 東京タワー
  [defaults setObject:@"139.745556" forKey:kLastLongitude];
  [defaults setObject:@"10.415038" forKey:kLastZoom];
  [ud registerDefaults:defaults];
  
  float lastLatitude = [ud floatForKey:kLastLatitude];
  float lastLongitude = [ud floatForKey:kLastLongitude];
  float lastZoom = [ud floatForKey:kLastZoom];
  
  [mapView_ setZoom:lastZoom];
  
  CLLocationCoordinate2D coordinate;
  coordinate.latitude = lastLatitude;
  coordinate.longitude = lastLongitude;
  [mapView_ setCenterCoordinate:coordinate];
  
  mapView_.delegate = self;
    
  [self.view addSubview:mapView_];
  
  // 現在地マーク
  CLLocationCoordinate2D defaultCenterCoordinate;
  defaultCenterCoordinate.latitude = 0.0;
  defaultCenterCoordinate.longitude = 0.0;
  _currentLocationView = [[MMAnnotationView alloc] initWithCoordinate:defaultCenterCoordinate mapView:mapView_];
  _currentLocationView.tag = kCurrentLocationPinTag;
  _currentLocationView.animationDuration *= 2.0;
  UIImage *image = [UIImage imageNamed:@"current_icon.png"];
  _currentLocationView.image = image;
  _currentLocationView.centerOffset = CGPointMake(-image.size.width/2, -image.size.height/2);
  [mapView_ addAnnotation:_currentLocationView];
  
  // MyCLQuery
  _locationQuery = [[MyCLQuery alloc] initWithDelegate:self];
  [_locationQuery startQuery];
  
  // 現在地ボタン
  {
    _currentLocationBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _currentLocationBtn.alpha = 0.8;
    _currentLocationBtn.frame = CGRectMake(10.0f, 10.0f, 70.0f, 30.0f);
    [_currentLocationBtn setTitle:[NSString stringWithUTF8String:"現在地"] forState:UIControlStateNormal];
    float margin = 5.0f;
    float originy = mapViewBounds.size.height - _currentLocationBtn.frame.size.height - margin;
    _currentLocationBtn.frame = CGRectMake(margin, originy, _currentLocationBtn.frame.size.width, _currentLocationBtn.frame.size.height);
    [_currentLocationBtn addTarget:self action:@selector(currentLocation) forControlEvents:UIControlEventTouchUpInside];
    [mapView_ addSubview:_currentLocationBtn];
  }
  
  // 検索ボタン
  {
    _searchBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _searchBtn.alpha = 0.8;
    _searchBtn.frame = CGRectMake(10.0f, 10.0f, 70.0f, 30.0f);
    [_searchBtn setTitle:[NSString stringWithUTF8String:"検　索"] forState:UIControlStateNormal];
    float margin = 5.0f;
    float originx = mapViewBounds.size.width - _searchBtn.frame.size.width - margin;
    float originy = mapViewBounds.size.height - _searchBtn.frame.size.height - margin;
    _searchBtn.frame = CGRectMake(originx, originy, _searchBtn.frame.size.width, _searchBtn.frame.size.height);
    [_searchBtn addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
    [mapView_ addSubview:_searchBtn];
  }
  
  // 再検索ボタン（最初は非表示）
  {
    _researchBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _researchBtn.frame = CGRectMake(10.0f, 10.0f, 70.0f, 30.0f);
    _researchBtn.alpha = 0.8;
    [_researchBtn setTitle:[NSString stringWithUTF8String:"再検索"] forState:UIControlStateNormal];
    float margin = 5.0f;
    float originx = mapViewBounds.size.width - _searchBtn.frame.size.width - _researchBtn.frame.size.width - margin*2;
    float originy = mapViewBounds.size.height - _researchBtn.frame.size.height - margin;
    _researchBtn.frame = CGRectMake(originx, originy, _researchBtn.frame.size.width, _researchBtn.frame.size.height);
    [_researchBtn addTarget:self action:@selector(doSearch) forControlEvents:UIControlEventTouchUpInside];
    [mapView_ addSubview:_researchBtn];
    _researchBtn.hidden = YES;
  }
  
  // クリアボタン（最初は非表示）
  {
    _searchClearBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _searchClearBtn.alpha = 0.8;
    _searchClearBtn.frame = CGRectMake(10.0f, 10.0f, 70.0f, 30.0f);
    [_searchClearBtn setTitle:[NSString stringWithUTF8String:"クリア"] forState:UIControlStateNormal];
    float margin = 5.0f;
    float originx = mapViewBounds.size.width - _searchBtn.frame.size.width - _researchBtn.frame.size.width - _searchClearBtn.frame.size.width - margin*3;
    float originy = mapViewBounds.size.height - _searchClearBtn.frame.size.height - margin;
    _searchClearBtn.frame = CGRectMake(originx, originy, _searchClearBtn.frame.size.width, _searchClearBtn.frame.size.height);
    [_searchClearBtn addTarget:self action:@selector(searchClear) forControlEvents:UIControlEventTouchUpInside];
    [mapView_ addSubview:_searchClearBtn];
    _searchClearBtn.hidden = YES;
  }
  
  // 前回のピン復元
  for (int i = 0; i < kMaxAnnotationsCount; i++) {
    NSString *address = [ud objectForKey:[NSString stringWithFormat:kAnnotationAddress, i]];
    //    NSLog(@"address:%@", address);
    if (!address) break;
    float latitude = [ud floatForKey:[NSString stringWithFormat:kAnnotationLatitude, i]];
    float longitude = [ud floatForKey:[NSString stringWithFormat:kAnnotationLongitude, i]];
    //    NSLog(@"address=%@ latitue=%f longitude=%f", address, latitude, longitude);
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = latitude;
    coordinate.longitude = longitude;
    MMAnnotationView *anno = [[MMAnnotationView alloc] initWithCoordinate:coordinate mapView:mapView_];
    anno.image = [UIImage imageNamed:@"selfpin.png"];
    anno.tag = kSelfPinTag;
    anno.title = address;
    [mapView_ addAnnotation:anno animated:YES];
  }
  
  // ナビゲーションバー非表示
  [self.navigationController setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 起動時＆他Controllerから戻った時
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  if (self.navigationController.navigationBarHidden) return; // 起動時
  
  [self.navigationController setNavigationBarHidden:YES animated:YES];
  UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
  [self adjust:orientation];
}

// viewWillAppearと同じくだけど、iPadで横向きで起動した時これがないとadjustしないので
- (void) viewDidAppear:(BOOL)animated {
  [self.navigationController setNavigationBarHidden:YES animated:YES];
  UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
  [self adjust:orientation];
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//  return YES;
//}

// 端末の向きを変えた時
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
  [self adjust:interfaceOrientation];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar*)searchBar {

//  NSLog(@"text=%@", searchBar.text);

  _lastSearchText = [searchBar.text retain];
  
  [self doSearch];
  [searchBar removeFromSuperview];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
  [searchBar removeFromSuperview];
}

#pragma mark - CLLocationManagerDelegate Methods

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
  //  NSLog(@"description: %@ || latlong: %f, %f || alt: %f || timestamp: %@", newLocation.description, newLocation.coordinate.latitude, newLocation.coordinate.longitude, newLocation.altitude, newLocation.timestamp);
  
  if (-[newLocation.timestamp timeIntervalSinceNow] > 5.0) return;
  if (newLocation.horizontalAccuracy > 2000.0) return;
  
  _lastCoordinate = newLocation.coordinate;
  
  
  [_currentLocationView setCoordinate:newLocation.coordinate animated:YES];
  
  
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
  switch ([error code]) {
    case kCLErrorDenied:
      NSLog(@"ユーザが拒否しました");
      break;
    case kCLErrorLocationUnknown:
      NSLog(@"位置情報を突き止められません");
      break;
    default:
      break;
  }
}

#pragma mark - Private

- (void)adjust:(UIInterfaceOrientation)orientation {
  CGRect rect = [self mapViewBounds];
  
  CGFloat x, y;
  CGFloat width, height;
	if ((orientation == UIInterfaceOrientationLandscapeLeft)
      || (orientation == UIInterfaceOrientationLandscapeRight)) {
    x = rect.origin.y;
    y = rect.origin.x;
    width = rect.size.height;
    height = rect.size.width;
	} else {
    x = rect.origin.x;
    y = rect.origin.y;
    width = rect.size.width;
    height = rect.size.height;
	}
  
  {
    float margin = 5.0f;
    float originx = margin;
    float originy = height - _currentLocationBtn.frame.size.height - margin;
    _currentLocationBtn.frame = CGRectMake(originx, originy, _currentLocationBtn.frame.size.width, _currentLocationBtn.frame.size.height);
  }
  {
    float margin = 5.0f;
    float originx = width - _searchBtn.frame.size.width - margin;
    float originy = height - _searchBtn.frame.size.height - margin;
    _searchBtn.frame = CGRectMake(originx, originy, _searchBtn.frame.size.width, _searchBtn.frame.size.height);
  }
  {
    float margin = 5.0f;
    float originx = width - _searchBtn.frame.size.width - _researchBtn.frame.size.width - margin*2;
    float originy = height - _researchBtn.frame.size.height - margin;
    _researchBtn.frame = CGRectMake(originx, originy, _researchBtn.frame.size.width, _researchBtn.frame.size.height);
  }
  {
    float margin = 5.0f;
    float originx = width - _searchBtn.frame.size.width - _researchBtn.frame.size.width - _searchClearBtn.frame.size.width - margin*3;
    float originy = height - _searchClearBtn.frame.size.height - margin;
    _searchClearBtn.frame = CGRectMake(originx, originy, _searchClearBtn.frame.size.width, _searchClearBtn.frame.size.height);
  }
  
  _searchBar.frame = CGRectMake(_searchBar.frame.origin.x, _searchBar.frame.origin.y, width, _searchBar.frame.size.height);
  
  mapView_.frame = CGRectMake(x, y, width, height);
}

- (void)search {
  [_searchBar removeFromSuperview];
  [_searchBar release], _searchBar = nil;
  
  _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(mapView_.frame.origin.x, -mapView_.frame.origin.y, mapView_.frame.size.width, 44.0f)];
  _searchBar.delegate = self;
  _searchBar.showsCancelButton = YES;
  _searchBar.translucent = YES;
  _searchBar.placeholder = @"検索";
  _searchBar.keyboardType = UIKeyboardTypeDefault;
  _searchBar.barStyle = UIBarStyleBlack;
  [_searchBar becomeFirstResponder];
  
  [mapView_ addSubview:_searchBar];
}

- (void)currentLocation {
//  NSLog(@"currentLocation");
  if (_lastCoordinate.latitude != 0.0 && _lastCoordinate.longitude != 0.0) {
    [mapView_ setCenterCoordinate:_lastCoordinate animated:YES];
  }
}

- (void)doSearch {
  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
  
  [self searchClear];
  
  NSString *urlString = [NSString stringWithFormat:kLocalSearch, mapView_.centerCoordinate.latitude, mapView_.centerCoordinate.longitude, _lastSearchText, kYahooDeveloperID];
//  NSLog(@"url=%@", urlString);
//  NSLog(@"searchText=%@", _lastSearchText);
  urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  
  NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
  [NSURLConnection sendAsynchronousRequest:request
                                     queue:[NSOperationQueue mainQueue]
                         completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                           if (error)  return;
                           
                           NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                           id jresult = [result JSONValue];
                           [result release];
                           
                           NSDictionary *dic = (NSDictionary *)jresult;
                           
                           [_featureArray release], _featureArray = nil;
                           _featureArray = [[dic objectForKey:@"Feature"] retain];
                           //                           NSLog(@"featureArray count=%d", featureArray.count);
                           for (NSDictionary *f in _featureArray) {
                             NSString *name = [f objectForKey:@"Name"];
                             //                             NSLog(@"name=%@", name);
                             NSString *id = [f objectForKey:@"Id"];
//                             NSLog(@"id=%d", id);
                             
                             NSDictionary *geometryDic = [f objectForKey:@"Geometry"];
                             NSString *coordinates = [geometryDic objectForKey:@"Coordinates"];
                             //                             NSLog(@"coordinates=%@", coordinates);
                             NSArray *coorArray = [coordinates componentsSeparatedByString:@","];
                             float lat = [[coorArray objectAtIndex:1] floatValue];
                             float lon = [[coorArray objectAtIndex:0] floatValue];
                             //                             NSLog(@"lat=%f lon=%f", lat, lon);
                             CLLocationCoordinate2D coordinate;
                             coordinate.latitude = lat;
                             coordinate.longitude = lon;
                             
                             MyAnnotationView *anno = [[MyAnnotationView alloc] initWithCoordinate:coordinate mapView:mapView_];
                             anno.tag = kSearchPinTag;
                             anno.localSearchId = id;
                             anno.title = name;
                             [mapView_ addAnnotation:anno animated:YES];
                             [anno release];
                           }
                           
                           if (_featureArray.count > 0) {
                             _researchBtn.hidden = NO;
                             _searchClearBtn.hidden = NO;
                           }
                           
                           [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                           
                         }];
}

- (void)searchClear {
  for (MMAnnotationView *annotationView in mapView_.annotations) {
    if (annotationView.tag == kSearchPinTag) {
      [annotationView removeFromSuperview];
    }
  }
  _researchBtn.hidden = YES;
  _searchClearBtn.hidden = YES;
}

- (CGRect)mapViewBounds {
  CGRect applicationFrame = [UIScreen mainScreen].applicationFrame;
  CGRect mainScreenBounds = [UIScreen mainScreen].bounds;
  
  float statusBarWidth = mainScreenBounds.size.width - applicationFrame.size.width;
  float statusBarHeight = mainScreenBounds.size.height - applicationFrame.size.height;
  CGRect rect = CGRectMake(-statusBarWidth, -statusBarHeight, mainScreenBounds.size.width, mainScreenBounds.size.height);
  return rect;
}

#pragma mark - MMMapViewDelegate Methods

- (void)doubleTap:(MMMapView *)map point:(CGPoint)point {
    //  NSLog(@"doubleTapOnMap!!!");
}

- (void)singleTap:(MMMapView *)map point:(CGPoint)point {
//  NSLog(@"singleTapOnMap!!!");
}

- (void)singleTapTwoFingers:(MMMapView *)map point:(CGPoint)point {
    //  NSLog(@"singleTapTwoFingersOnMap!!!");
}

- (void)longSingleTap:(MMMapView *)map point:(CGPoint)point {
    //  NSLog(@"longSingleTapOnMap!!!");
  
  int count = 0;
  for (MMAnnotationView *anno in mapView_.annotations) {
    if (anno.tag == kSelfPinTag) count++;
  }
  if (count >= kMaxAnnotationsCount) {
    NSString *message = [NSString stringWithFormat:@"ピンは最大%dまでです。", kMaxAnnotationsCount];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"閉じる", nil];
    [alert show];
    [alert release];
    return;
  }
  
  CLLocationCoordinate2D coordinate = [mapView_ pixelToCoordinate:point];
    
  MMAnnotationView *annotationView = [[MMAnnotationView alloc] initWithCoordinate:coordinate mapView:mapView_];
  annotationView.image = [UIImage imageNamed:@"selfpin.png"];
  annotationView.tag = kSelfPinTag;
  annotationView.title = @"住所取得中...";
  [mapView_ addAnnotation:annotationView animated:YES];
  
  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
  
  NSString *urlString = [NSString stringWithFormat:kReverseGeocoder, coordinate.latitude, coordinate.longitude, kYahooDeveloperID];
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
                             NSString *addressStr = [propertyDic objectForKey:@"Address"];
//                             NSLog(@"address=%@", addressStr);
                             if ([addressStr isEqualToString:@""]) {
                               addressStr = @"住所不明";
                             }
                             
                             annotationView.title = addressStr;
                             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                           }];
  
  
  [self performSelector:@selector(openInfoWindow:) withObject:annotationView afterDelay:annotationView.animationDuration];
}

- (void)openInfoWindow:(MMAnnotationView *)annotationView {
    [annotationView onClick];
}

- (void)beforeMapMove:(MMMapView *)mapView {
    //  NSLog(@"beforeMapMove!!!");
}

- (void)afterMapMove:(MMMapView *)mapView {
    //  NSLog(@"afterMapMove!!!");
    
}

- (void)beforeMapZoom:(MMMapView *)mapView {
    //  NSLog(@"beforeMapZoom!!!");
}

- (void)afterMapZoom:(MMMapView *)mapView {
    //  NSLog(@"afterMapZoom!!!");
    
    //  [self check];
}

- (void)tapOnPopup:(MMMapView *)mapView annotationView:(MMAnnotationView *)annotationView control:(UIControl *)control {
  if ([annotationView isKindOfClass:[MyAnnotationView class]]) {
    MyAnnotationView *view = (MyAnnotationView *)annotationView;
    for (NSDictionary *dic in _featureArray) { // _featureArrayがbac_exc
      NSString *currentId = [dic objectForKey:@"Id"];
      if ([currentId isEqualToString:view.localSearchId]) {
        UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchDetailTableViewController"];
        SearchDetailTableViewController *searchDetainTableViewController = (SearchDetailTableViewController *)controller;
        searchDetainTableViewController.feature = dic;
  
        [self.navigationController pushViewController:searchDetainTableViewController animated:YES];
        break;
      }
    }
  } else {
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailTableViewController"];
    DetailTableViewController *detainTableViewController = (DetailTableViewController *)controller;
    detainTableViewController.mapView = mapView_;
    detainTableViewController.annotationView = annotationView;
    
    [self.navigationController pushViewController:detainTableViewController animated:YES];
  }
}

- (void)zoomIn:(MMMapView *)mapView point:(CGPoint)point {
    int nowFloor = floorf(mapView.zoom);
    float nextZoom = nowFloor + 0.415038f;
    if (nextZoom - mapView.zoom < 0.2) {
        nextZoom += 1.0f;
    }
    nextZoom = fmin(nextZoom, [mapView.map maxZoom]);
    
    if (nextZoom == mapView.zoom) return;
    if (![mapView containPoint:point]) return;
    
    float zoomFactor = exp2f(nextZoom - mapView.zoom);
    
    [mapView zoomTo:zoomFactor point:point];
}

- (void)zoomOut:(MMMapView *)mapView point:(CGPoint)point {
    int nowFloor = floorf(mapView.zoom);
    float nextZoom = nowFloor - 0.584962f;
    if (mapView.zoom - nextZoom < 0.2) {
        nextZoom -= 1.0f;
    }
    nextZoom = fmax(nextZoom, [mapView.map minZoom]);
    
    if (nextZoom == mapView.zoom) return;
    if (![mapView containPoint:point]) return;
    
    float zoomFactor = exp2f(nextZoom - mapView.zoom);
    
    [mapView zoomTo:zoomFactor point:point];
}

- (NSUInteger)cacheCapacity {
  return 2000;
}


@end
