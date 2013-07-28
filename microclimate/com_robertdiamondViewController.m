//
//  com_robertdiamondViewController.m
//  microclimate
//
//  Created by Robert Diamond on 7/27/13.
//  Copyright (c) 2013 Robert Diamond. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "com_robertdiamondViewController.h"
#import "WeatherAPI.h"
#import "WeatherMapAnnotation.h"
#import "WeatherMapAnnotationView.h"
#import "WeatherConditions.h"

@interface com_robertdiamondViewController () <CLLocationManagerDelegate,MKMapViewDelegate>
@property (nonatomic) MKMapView *mapView;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLLocation *currentBestLocation;
@property (nonatomic) NSMutableSet *stations;
@property (nonatomic) NSMutableDictionary *conditions;
@end

@implementation com_robertdiamondViewController

+ (MKMapView *)sharedMapView
{
    static MKMapView *__mapView = nil;
    if (!__mapView) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            __mapView = [[MKMapView alloc] initWithFrame:CGRectZero];
        });
    }
    return __mapView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _conditions = [NSMutableDictionary new];
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
        [_locationManager startMonitoringSignificantLocationChanges];
    } else {
        _locationManager.desiredAccuracy = 100;
        [_locationManager startUpdatingLocation];
    }
	_mapView = [[self class] sharedMapView];
    _mapView.frame = self.view.frame;
    _mapView.delegate = self;
    [self.view addSubview:_mapView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [self locationManager:manager didUpdateLocations:@[newLocation]];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *bestLocation = [locations lastObject];
    if (bestLocation) {
        if (!_currentBestLocation) {
            _mapView.region = MKCoordinateRegionMake(bestLocation.coordinate, MKCoordinateSpanMake(.1, .1));
        }
        _currentBestLocation = bestLocation;
        __weak com_robertdiamondViewController *weakSelf = self;
        [WeatherAPI fetchStationsNearLatitude:bestLocation.coordinate.latitude longitude:bestLocation.coordinate.longitude withCompletionBlock:^(NSArray *results) {
            com_robertdiamondViewController *strongSelf = weakSelf;
            if (strongSelf) {
                NSLog(@"Results: %@", results);
                NSMutableSet *resultSet = [NSMutableSet new];
                [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    WeatherMapAnnotation *annotation = [[WeatherMapAnnotation alloc] initWithDictionary:obj];
                    if (annotation) {
                        [resultSet addObject:annotation];
                    }
                }];
                if (_stations) {
                    NSMutableSet *removedStations = [_stations copy];
                    [removedStations minusSet:resultSet];
                    [resultSet minusSet:_stations];
                    [strongSelf->_mapView removeAnnotations:[removedStations allObjects]];
                } else {
                    strongSelf->_stations = [NSMutableSet new];
                }
                [resultSet enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                    [strongSelf->_stations addObject:obj];
                    [strongSelf->_mapView addAnnotation:obj];
                }];
            }
        } failureBlock:nil];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation
{
    WeatherMapAnnotation *annot = (WeatherMapAnnotation *)annotation;
    
    WeatherMapAnnotationView *view = (WeatherMapAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"weathermap"];
    if (!view) {
        view = [[WeatherMapAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"weathermap"];
    }
    
    if ([annot.type isEqualToString:@"airport"]) {
        view.image = [UIImage imageNamed:@"Airport-Blue-icon"];
    } else {
        view.image = [UIImage imageNamed:@"dg950_s2_icon"];
    }
    view.bounds = CGRectMake(0, 0, 22, 22);
    view.canShowCallout = YES;
    
    __weak com_robertdiamondViewController *weakSelf = self;
    __weak WeatherMapAnnotationView *weakView = view;
    CLLocation *stationLoc = [[CLLocation alloc] initWithLatitude:annot.coordinate.latitude longitude:annot.coordinate.longitude];
    if ([stationLoc distanceFromLocation:_currentBestLocation] <= 2000 && (_conditions[annot.title][@"lastUpdate"] == nil || [[NSDate date] timeIntervalSinceDate:_conditions[annot.title][@"lastUpdate"]] > 90)) {
        _conditions[annot.title] = [@{@"lastUpdate": [NSDate date]} mutableCopy];
        [WeatherAPI fetchConditionsForStation:annot withCompletionBlock:^(NSDictionary *result) {
            com_robertdiamondViewController *strongSelf = weakSelf;
            if (strongSelf) {
                WeatherMapAnnotationView *strongView = weakView;
                if (result) {
                    NSLog(@"Conditions at %@: %@", annot.title, result);
                    strongSelf->_conditions[annot.title] = [result mutableCopy];
                    strongSelf->_conditions[annot.title][@"lastUpdate"] = [NSDate date];
                    annot.conditions = [[WeatherConditions alloc] initWithDictionary:result];
                    [strongView setNeedsDisplay];
                }
            }
        } failureBlock:nil];
    }
    
    return view;
}

@end
