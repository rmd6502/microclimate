//
//  WeatherMapAnnotationView.h
//  microclimate
//
//  Created by Robert Diamond on 7/28/13.
//  Copyright (c) 2013 Robert Diamond. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface WeatherMapAnnotationView : MKAnnotationView

@property (nonatomic,weak) id fetcher;

@end
