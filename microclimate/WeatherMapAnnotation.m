//
//  WeatherMapAnnotation.m
//  microclimate
//
//  Created by Robert Diamond on 7/28/13.
//  Copyright (c) 2013 Robert Diamond. All rights reserved.
//

#import "WeatherMapAnnotation.h"

@interface WeatherMapAnnotation ()
@end

@implementation WeatherMapAnnotation
- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [self init];
    if (self) {
        _coordinate = CLLocationCoordinate2DMake([dictionary[@"lat"] doubleValue], [dictionary[@"lon"] doubleValue]);
        if (dictionary[@"icao"]) {
            _type = @"airport";
            _title = dictionary[@"icao"];
            _subTitle = [NSString stringWithFormat:@"%@, %@, %@", dictionary[@"city"], dictionary[@"state"], dictionary[@"country"]];
        } else {
            _type = @"pws";
            _title = dictionary[@"id"];
            _subTitle = dictionary[@"neighborhood"];
        }
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"WeatherMapAnnotation at %p name %@ subtitle %@ location %f,%f", self, _title, _subTitle, _coordinate.latitude, _coordinate.longitude];
}

- (BOOL)isEqual:(id)object
{
    return ([object isKindOfClass:[WeatherMapAnnotation class]] && [((WeatherMapAnnotation *)object).title isEqualToString:_title] && [((WeatherMapAnnotation *)object).subTitle isEqualToString:_subTitle]);
}

- (NSUInteger)hash
{
    return _title.hash + _subTitle.hash;
}
@end
