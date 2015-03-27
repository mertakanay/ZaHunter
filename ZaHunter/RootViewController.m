//
//  ViewController.m
//  ZaHunter
//
//  Created by Mert Akanay on 25.03.2015.
//  Copyright (c) 2015 MobileMakers. All rights reserved.
//

#import "RootViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "MapViewController.h"

@interface RootViewController () <CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate>

@property CLLocationManager *locationManager;
@property NSArray *locationArray;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@property NSIndexPath *selectedIndex;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.locationManager = [CLLocationManager new];
    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.delegate = self;


}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    MKMapItem *aMapItem = self.locationArray[indexPath.row];
    cell.textLabel.text = aMapItem.name;
    double distance = [aMapItem.placemark.location distanceFromLocation:self.locationManager.location];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%f",distance];

//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@[NSString stringWithFormat:@"%f",distance]];
//    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@[NSString stringWithFormat:@"%f",distance] ascending:YES];
//
//    for (MKMapItem *mapItem in self.locationArray) {
//
//        if ([cell.detailTextLabel.text intValue]> 10000)
//        {
//            [self.locationArray ]; //need to delete the cell according to object
//        }
//    }


    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndex = indexPath;
}

#pragma mark - CLLocationManagerDelegateMethods
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for (CLLocation *location in locations) {
        if (location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000)
        {

            [self.locationManager stopUpdatingLocation];

            [self findPizzeriaNearby:location];
        }
    }
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    [self.locationManager startUpdatingLocation];
}

-(void)findPizzeriaNearby:(CLLocation *)location
{
    MKLocalSearchRequest *request = [MKLocalSearchRequest new];
    request.naturalLanguageQuery = @"pizza";
    request.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(0.1, 0.1));
    MKLocalSearch *search = [[MKLocalSearch alloc]initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        self.locationArray = response.mapItems;
        
        [self.tableView reloadData];
    }];
}
- (IBAction)onRouteButtonPressed:(UIButton *)sender
{
    MKMapItem *mapItem = self.locationArray[self.selectedIndex.row];
    [self pullDirectionsToMapItem:mapItem];
}

-(void)pullDirectionsToMapItem:(MKMapItem *)mapItem
{
    MKDirectionsRequest *request = [MKDirectionsRequest new];
    request.source  = [MKMapItem mapItemForCurrentLocation];
    request.destination = mapItem;
    MKDirections *direction = [[MKDirections alloc]initWithRequest:request];
    [direction calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        NSArray *routes = response.routes;
        MKRoute *theRoute = [routes objectAtIndex:0];


        NSMutableString *stepString = [NSMutableString new];
        int stepCount = 1;

        for (MKRouteStep *step in theRoute.steps)
        {
            [stepString appendFormat:@"%i. %@\n", stepCount, step.instructions];
            stepCount++;
        }
        self.textView.text = stepString;
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MapViewController *mapVC = [segue destinationViewController];
    mapVC.locationArray = self.locationArray;
}


@end
