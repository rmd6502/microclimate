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
@property (nonatomic) NSTimer *updateTimer;
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
    _mapView.showsUserLocation = YES;
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
        [WeatherAPI fetchStationsNearLatitude:bestLocation.coordinate.latitude longitude:bestLocation.coordinate.longitude withCompletionBlock:^(id fetcher, NSArray *results) {
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
                    NSMutableSet *removedStations = [_stations mutableCopy];
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
    if (annotation == mapView.userLocation) {
        return nil;
    }
    WeatherMapAnnotation *annot = (WeatherMapAnnotation *)annotation;
    
    WeatherMapAnnotationView *view = (WeatherMapAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"weathermap"];
    if (!view) {
        view = [[WeatherMapAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"weathermap"];
    }
    
    annot.theView = view;
    if ([annot.type isEqualToString:@"airport"]) {
        view.image = [UIImage imageNamed:@"Airport-Blue-icon"];
    } else {
        view.image = [UIImage imageNamed:@"dg950_s2_icon"];
    }
    view.bounds = CGRectMake(0, 0, 22, 22);
    view.canShowCallout = YES;
        
    return view;
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    if (_updateTimer.isValid) {
        [_updateTimer invalidate];
    }
    __weak com_robertdiamondViewController *weakSelf = self;
    _updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(_doUpdateMap:) userInfo:weakSelf repeats:NO];
}

- (void)_doUpdateMap:(NSTimer *)timer
{
    com_robertdiamondViewController *strongSelf = timer.userInfo;
    if (strongSelf) {
        if (strongSelf->_currentBestLocation != nil && (strongSelf->_mapView.region.center.latitude != strongSelf->_currentBestLocation.coordinate.latitude || strongSelf->_mapView.region.center.longitude != strongSelf->_currentBestLocation.coordinate.longitude)) {
            if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
                [strongSelf->_locationManager stopMonitoringSignificantLocationChanges];
            } else {
                [strongSelf->_locationManager stopUpdatingLocation];
            }
            strongSelf->_currentBestLocation = [[CLLocation alloc] initWithLatitude:strongSelf->_mapView.region.center.latitude longitude:strongSelf->_mapView.region.center.longitude];
            [self locationManager:strongSelf->_locationManager didUpdateLocations:@[strongSelf->_currentBestLocation]];
        }

        [strongSelf->_mapView.annotations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (![obj isKindOfClass:[WeatherMapAnnotation class]]) {
                return;
            }
            WeatherMapAnnotation *annotation = obj;
            __weak WeatherMapAnnotationView *weakView = (WeatherMapAnnotationView *)annotation.theView;
            CLLocation *stationLoc = [[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude];
            __weak com_robertdiamondViewController *weakSelf = strongSelf;
            if ([stationLoc distanceFromLocation:_currentBestLocation] <= 5000 && (strongSelf->_conditions[annotation.title][@"lastUpdate"] == nil || [[NSDate date] timeIntervalSinceDate:strongSelf->_conditions[annotation.title][@"lastUpdate"]] > 90)) {
                strongSelf->_conditions[annotation.title] = [@{@"lastUpdate": [NSDate date]} mutableCopy];
                ((WeatherMapAnnotationView *)annotation.theView).fetcher = [WeatherAPI fetchConditionsForStation:annotation withCompletionBlock:^(id fetcher, NSDictionary *result) {
                    com_robertdiamondViewController *strongSelf = weakSelf;
                    WeatherMapAnnotationView *strongView = weakView;
                    if (strongSelf && strongView && strongView.fetcher == fetcher) {
                        if (result) {
                            NSLog(@"Conditions at %@: %@", annotation.title, result);
                            strongSelf->_conditions[annotation.title] = [result mutableCopy];
                            strongSelf->_conditions[annotation.title][@"lastUpdate"] = [NSDate date];
                            annotation.conditions = [[WeatherConditions alloc] initWithDictionary:result];
                            [strongView setNeedsLayout];
                        }
                    }
                } failureBlock:nil];
            }
        }];
    }
}

@end
