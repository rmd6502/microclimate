//
//  WeatherMapAnnotation.h
//  microclimate
//
//  Created by Robert Diamond on 7/28/13.
//  Copyright (c) 2013 Robert Diamond. All rights reserved.
//

#import <MapKit/MapKit.h>

@class  WeatherConditions;
@interface WeatherMapAnnotation : NSObject<MKAnnotation>
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) NSString *type;
@property (nonatomic,copy) NSString *title;
@property (nonatomic) NSString *subTitle;
@property (nonatomic) WeatherConditions *conditions;
@property (nonatomic) MKAnnotationView *theView;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
