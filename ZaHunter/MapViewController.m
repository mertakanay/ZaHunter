//
//  MapViewController.m
//  ZaHunter
//
//  Created by Mert Akanay on 25.03.2015.
//  Copyright (c) 2015 MobileMakers. All rights reserved.
//

#import "MapViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface MapViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property MKMapItem *mapItem;
@property MKPointAnnotation *pizzeriaAnnotation;
@property CLLocationManager *locationManager;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.locationManager = [CLLocationManager new];

    [self.locationManager requestWhenInUseAuthorization];

    self.mapView.showsUserLocation = YES;

    for (int i = 0; i<self.locationArray.count; i++)
    {
        self.mapItem = self.locationArray[i];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(self.mapItem.placemark.location.coordinate.latitude, self.mapItem.placemark.location.coordinate.longitude);
        self.pizzeriaAnnotation = [MKPointAnnotation new];
        self.pizzeriaAnnotation.title = self.mapItem.name;
        self.pizzeriaAnnotation.coordinate = coordinate;

        [self.mapView addAnnotation:self.pizzeriaAnnotation];

    }

}
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKPinAnnotationView *pinAnnotation = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:nil];

        if([annotation isEqual:mapView.userLocation])
        {
            return nil;
        }
    else
    {
        pinAnnotation.image = [UIImage imageNamed:@"pizza_256"];
        //image needs to be resized

    }

    pinAnnotation.canShowCallout = YES;
    pinAnnotation.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    return pinAnnotation;
}


- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay
{

    if ([overlay isKindOfClass:[MKPolyline class]])
    {

        MKPolylineView* aView = [[MKPolylineView alloc]initWithPolyline:(MKPolyline*)overlay] ;

        aView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];

        aView.lineWidth = 10;

        return aView;


    }else{

    return nil;

    }

}

@end
