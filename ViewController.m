//
//  ViewController.m
//  The Map
//
//  Created by Tuan Anh Le on 24.06.2017.
//  Copyright © 2017 sma fun. All rights reserved.
//

#import "ViewController.h"
@import GooglePlaces;
@import GooglePlacePicker;
@import GoogleMaps;

CGRect screenView;
NSInteger buttonPosX;
NSInteger buttonPosY;
NSInteger buttonWidth;
NSInteger buttonHeight;
NSInteger fontSize;
NSInteger againButtonY;
NSInteger againButtonW;
NSInteger againButtonH;
NSInteger againFontSize;
NSInteger buttonW;
NSInteger buttonH;
GMSCameraPosition *camera;
GMSMapView *mapView;
NSInteger currentZoom;
double latitude;
double longitude;

@interface ViewController ()<CLLocationManagerDelegate, GMSPlacePickerViewControllerDelegate, GMSAutocompleteViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UIButton *goButton;
@property (strong, nonatomic) IBOutlet UIButton *plussButton;
@property (strong, nonatomic) IBOutlet UIButton *minusButton;
@property (strong, nonatomic) IBOutlet UIButton *searchAgainButton;
@property (nonatomic,strong)CLLocationManager * myLocationManger;

@end


@implementation ViewController{
    GMSPlacesClient *_placesClient;
    GMSPlacePickerViewController *_placePicker;
}
@synthesize goButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _placesClient = [GMSPlacesClient sharedClient];
    [self initialiseVariable];
    [self checkLocationAvailable];
    [self createButton];
    
     [self.view layoutIfNeeded];
}

//Chekcs if Location Services are Enabled
- (void) checkLocationAvailable{
    if ([CLLocationManager locationServicesEnabled]) {
        self.myLocationManger = [[CLLocationManager alloc] init];
        self.myLocationManger.delegate = self;
        
        [self.myLocationManger startUpdatingLocation];
        
        // Check for iOS 8
        if ([self.myLocationManger respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.myLocationManger requestWhenInUseAuthorization];
            [self.myLocationManger requestAlwaysAuthorization];
        }
    }
    else{
        //Location Services are available we will need software to ask to turn this On
        //The user is SOL if they refuse to turn on Location Services
        NSLog(@"Location Services not enabled");
        
        
    }

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // Send the user to the Settings for this app
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:settingsURL];
    }
}

- (void)initialiseVariable {
    screenView      = [[UIScreen mainScreen] bounds];
    buttonWidth     = screenView.size.width/2;
    buttonHeight    = screenView.size.height/15;
    buttonPosX      = (screenView.size.width/2) - (buttonWidth/2);
    buttonPosY      = screenView.size.height/2.5;
    
    buttonW         = screenView.size.width/12;
    buttonH         = screenView.size.height/15;
    
    againButtonY    = screenView.size.height - 50;
    againButtonW    = screenView.size.width/3;
    againButtonH    = screenView.size.height/20;
    againFontSize   = screenView.size.width/18;
    
    fontSize        = screenView.size.width/15;
    currentZoom     = 6;
}


- (void)createButton {
    goButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonPosX, buttonPosY, buttonWidth, buttonHeight)];
    [goButton setTitle:@"Go" forState:UIControlStateNormal];
    [goButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    goButton.titleLabel.font = [UIFont systemFontOfSize:fontSize];
    goButton.backgroundColor = [UIColor colorWithRed:(217/255.0) green:(217/255.0) blue:(217/255.0) alpha:(0.50)];
    goButton.layer.cornerRadius = 5.0;
    goButton.layer.borderWidth = 1.0;
    goButton.layer.borderColor = [[UIColor blackColor] CGColor];
    [goButton addTarget:self
                 action:@selector(searchAction)
       forControlEvents:UIControlEventTouchUpInside];
    goButton.layer.masksToBounds = YES;
    goButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin |
                                UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:goButton];
}

- (void)createMinusButton {
    _plussButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonPosX-buttonW-5, againButtonY, buttonW, againButtonH)];
    [_plussButton setTitle:@"-" forState:UIControlStateNormal];
    [_plussButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _plussButton.titleLabel.font = [UIFont systemFontOfSize:25];
    _plussButton.backgroundColor = [UIColor colorWithRed:(217/255.0) green:(217/255.0) blue:(217/255.0) alpha:(0.50)];
    //_searchAgainButton.backgroundColor = [UIColor lightTextColor];
    _plussButton.layer.cornerRadius = 5.0;
    _plussButton.layer.borderWidth = 1.0;
    _plussButton.layer.borderColor = [[UIColor blackColor] CGColor];
    [_plussButton addTarget:self
                 action:@selector(zoomOutMapView:)
       forControlEvents:UIControlEventTouchUpInside];
    _plussButton.layer.masksToBounds = YES;
    _plussButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:_plussButton];
}

- (void)createPlussButton {
    _minusButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonPosX + buttonWidth + 5, againButtonY, buttonW, againButtonH)];
    [_minusButton setTitle:@"+" forState:UIControlStateNormal];
    [_minusButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _minusButton.titleLabel.font = [UIFont systemFontOfSize:fontSize];
    _minusButton.backgroundColor = [UIColor colorWithRed:(217/255.0) green:(217/255.0) blue:(217/255.0) alpha:(0.50)];
    //_searchAgainButton.backgroundColor = [UIColor lightTextColor];
    _minusButton.layer.cornerRadius = 5.0;
    _minusButton.layer.borderWidth = 1.0;
    _minusButton.layer.borderColor = [[UIColor blackColor] CGColor];
    [_minusButton addTarget:self
                 action:@selector(zoomInMapView:)
       forControlEvents:UIControlEventTouchUpInside];
    _minusButton.layer.masksToBounds = YES;
    _minusButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:_minusButton];
}

- (void)createSearchAgainButton {
    _searchAgainButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonPosX, againButtonY, buttonWidth, againButtonH)];
    [_searchAgainButton setTitle:@"Search againt" forState:UIControlStateNormal];
    [_searchAgainButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _searchAgainButton.titleLabel.font = [UIFont systemFontOfSize:againFontSize];
    _searchAgainButton.backgroundColor = [UIColor colorWithRed:(217/255.0) green:(217/255.0) blue:(217/255.0) alpha:(0.50)];
    //_searchAgainButton.backgroundColor = [UIColor lightGrayColor];
    _searchAgainButton.layer.cornerRadius = 5.0;
    _searchAgainButton.layer.borderWidth = 1.0;
    _searchAgainButton.layer.borderColor = [[UIColor blackColor] CGColor];
    [_searchAgainButton addTarget:self
                     action:@selector(searchAction)
           forControlEvents:UIControlEventTouchUpInside];
    _searchAgainButton.layer.masksToBounds = YES;
    _searchAgainButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:_searchAgainButton];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation
{
    //This method will show us that we recieved the new location
    NSLog(@"NewLatitude = %f",newLocation.coordinate.latitude );
    NSLog(@"NewLongitude =%f",newLocation.coordinate.longitude);
    NSLog(@"OldLatitude = %f",oldLocation.coordinate.latitude );
    NSLog(@"OldLongitude =%f",oldLocation.coordinate.longitude);
}

-(void)locationManager:(CLLocationManager *)manager
didFinishDeferredUpdatesWithError:(NSError *)error{
    NSLog(@"Error with Updating");
}

-(void)locationManager:(CLLocationManager *)manager
      didFailWithError:(NSError *)error
{
    [manager stopUpdatingLocation];
    NSLog(@"error%@",error);
    switch([error code])
    {
        case kCLErrorNetwork: // general, network-related error
        {
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Error"
                                          message:@"please check your network connection or that you are not in airplane mode"
                                          preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* cancel = [UIAlertAction
                                     actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                         
                                     }];
            [alert addAction:cancel];
        }
            break;
        case kCLErrorDenied:{
            //[alert release];
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Error"
                                          message:@"user has denied to use current Location "
                                          preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* cancel = [UIAlertAction
                                     actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                         
                                     }];
            [alert addAction:cancel];

        }
            break;
        default:
        {
            //[alert release];
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Error"
                                          message:@"unknown network error"
                                          preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* cancel = [UIAlertAction
                                     actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                         
                                     }];
            [alert addAction:cancel];

        }
            break;
    }

}

// To receive the results from the place picker 'self' will need to conform to
// GMSPlacePickerViewControllerDelegate and implement this code.
- (void)placePicker:(GMSPlacePickerViewController *)viewController didPickPlace:(GMSPlace *)place {
    // Dismiss the place picker, as it cannot dismiss itself.
    [viewController dismissViewControllerAnimated:YES completion:nil];
    
    NSLog(@"Place name %@", place.name);
    NSLog(@"Place address %@", place.formattedAddress);
    NSLog(@"Place attributions %@", place.attributions.string);
}

- (void)placePickerDidCancel:(GMSPlacePickerViewController *)viewController {
    // Dismiss the place picker, as it cannot dismiss itself.
    [viewController dismissViewControllerAnimated:YES completion:nil];
    
    NSLog(@"No place selected");
}

-(void)zoomInMapView:(id)sender
{
    GMSCameraUpdate *zoomCamera = [GMSCameraUpdate zoomIn];
    [mapView animateWithCameraUpdate:zoomCamera];
   
}

-(void) zoomOutMapView:(id)sender
{
    GMSCameraUpdate *zoomCamera = [GMSCameraUpdate zoomOut];
    [mapView animateWithCameraUpdate:zoomCamera];
    
}

-(void)ZoominOutMap:(CGFloat)level
{
    NSLog(@"Latitude = %f",latitude );
    NSLog(@"Longitude =%f",longitude);

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:latitude
                                                            longitude:longitude
                                                                 zoom:level];
    mapView.camera = camera;
}

- (void) searchAction{
    GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
    acController.delegate = self;
    
/*    camera = [GMSCameraPosition cameraWithLatitude:59.947120 longitude:11.024448 zoom:currentZoom];
    //mapView = [GMSMapView mapWithFrame:self.view.frame camera:camera];
    mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView.myLocationEnabled = YES;
    mapView.mapType = kGMSTypeSatellite;
    [acController.view addSubview:mapView];*/
    
    [self presentViewController:acController animated:YES completion:nil];
}


- (void)viewController:(GMSAutocompleteViewController *)viewController
didAutocompleteWithPlace:(GMSPlace *)place {
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"Place name %@", place.name);
    NSLog(@"Place address %@", place.formattedAddress);
    NSLog(@"Place attributions %@", place.attributions.string);
    NSLog(@"latitude %f", place.coordinate.latitude);
    NSLog(@"longitude %f", place.coordinate.longitude);
    latitude = place.coordinate.latitude;
    longitude = place.coordinate.longitude;
    
    camera = [GMSCameraPosition cameraWithLatitude:place.coordinate.latitude longitude:place.coordinate.longitude zoom:currentZoom];
    mapView = [GMSMapView mapWithFrame:self.view.frame camera:camera];
    mapView.myLocationEnabled = YES;
    mapView.mapType = kGMSTypeHybrid;
    [self.view addSubview:mapView];
    
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude);
    GMSMarker *marker = [GMSMarker markerWithPosition:position];
    marker.flat = YES;
    marker.groundAnchor = CGPointMake(0.5, 0.5);
    
    marker.map = mapView;
    
    [self createPlussButton];
    [self createMinusButton];
    [self createSearchAgainButton];
}

- (void)viewController:(GMSAutocompleteViewController *)viewController
didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    // TODO: handle the error.
    NSLog(@"Error: %@", [error description]);
}

// User canceled the operation.
- (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Turn the network activity indicator on and off again.
- (void)didRequestAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
