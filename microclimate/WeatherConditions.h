//
//  WeatherConditions.h
//  microclimate
//
//  Created by Robert Diamond on 7/28/13.
//  Copyright (c) 2013 Robert Diamond. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeatherConditions : NSObject

@property (nonatomic) float temp_c;
@property (nonatomic) float wind_deg;
@property (nonatomic) NSString *conditions;
@property (nonatomic) float wind_speed;
@property (nonatomic) float wind_gust;
@property (nonatomic) NSString *icon_url;

- (id)initWithDictionary:(NSDictionary *)dictionary;
@end
