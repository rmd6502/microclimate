//
//  WeatherConditions.m
//  microclimate
//
//  Created by Robert Diamond on 7/28/13.
//  Copyright (c) 2013 Robert Diamond. All rights reserved.
//

#import "WeatherConditions.h"

@implementation WeatherConditions

- (id)initWithDictionary:(NSDictionary *)dic
{
    self = [self init];
    if (self) {
        NSDictionary *dictionary = dic[@"current_observation"];
        _conditions = dictionary[@"weather"];
        _temp_c = [dictionary[@"temp_c"] floatValue];
        _wind_deg = [dictionary[@"wind_degrees"] floatValue];
        _wind_speed = [dictionary[@"wind_mph"] floatValue];
        _wind_gust = [dictionary[@"wind_gust_mph"] floatValue];
        _icon_url = dictionary[@"icon_url"];
    }
    return self;
}
@end
