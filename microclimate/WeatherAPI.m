//
//  WeatherAPI.m
//  microclimate
//
//  Created by Robert Diamond on 7/27/13.
//  Copyright (c) 2013 Robert Diamond. All rights reserved.
//

#import "WeatherAPI.h"
#import "WeatherMapAnnotation.h"
#import "WebOperation.h"

#define API_KEY @"5251971eeb9b38bc"
#define API_BASE @"http://api.wunderground.com/api/"

#define QUERY_PREFIX @"/q/"

#define FETCH_STATIONS_PATH @"geolookup"
#define CONDITIONS_PATH @"conditions"

@interface WeatherAPI ()
+ (NSString *)createRequestURLWithPath:(NSString *)path andQuery:(NSString *)query;
+ (NSString *)queryWithLatitude:(double)lat longitude:(double)lon;
+ (NSString *)queryWithStation:(WeatherMapAnnotation *)station;
@end

@implementation WeatherAPI

+ (NSString *)createRequestURLWithPath:(NSString *)path andQuery:(NSString *)query
{
    return [NSString stringWithFormat:@"%@%@/%@%@.json", API_BASE, API_KEY, path, query];
}

+ (NSString *)queryWithLatitude:(double)lat longitude:(double)lon
{
    return [NSString stringWithFormat:@"%@%.9f,%.9f", QUERY_PREFIX, lat, lon];
}

+ (NSString *)queryWithStation:(WeatherMapAnnotation *)station
{
    if ([station.type isEqualToString:@"pws"]) {
        return [NSString stringWithFormat:@"%@pws:%@", QUERY_PREFIX,station.title];
    } else {
        return [NSString stringWithFormat:@"%@%@", QUERY_PREFIX,station.title];
    }
}

+ (id)fetchStationsNearLatitude:(double)lat longitude:(double)lon withCompletionBlock:(ArrayCompletion)successBlock failureBlock:(ErrorCompletion)failureBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[self createRequestURLWithPath:FETCH_STATIONS_PATH andQuery:[self queryWithLatitude:lat longitude:lon]]]];
    request.timeoutInterval = 10.0f;
    [WebOperation webOperationWithRequest:request onComplete:^(WebOperation *operation) {
        NSError *error = nil;
        id result = nil;
        if (operation.data) {
            result = [NSJSONSerialization JSONObjectWithData:operation.data options:0 error:&error];
        }
        
        if (error) {
            if (failureBlock) {
                failureBlock(self,error);
            }
        } else {
            if (successBlock) {
                NSMutableArray *ret = [NSMutableArray new];
                NSArray *airports = result[@"location"][@"nearby_weather_stations"][@"airport"][@"station"];
                if (airports) {
                    [ret addObjectsFromArray:airports];
                }
                NSArray *pws = result[@"location"][@"nearby_weather_stations"][@"pws"][@"station"];
                if (pws) {
                    [ret addObjectsFromArray:pws];
                }
                successBlock(self,ret);
            }
        }
    }];
    return self;
}

+ (id)fetchConditionsForStation:(WeatherMapAnnotation *)station withCompletionBlock:(DictionaryCompletion)successBlock failureBlock:(ErrorCompletion)failureBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[self createRequestURLWithPath:CONDITIONS_PATH andQuery:[self queryWithStation:station]]]];
    request.timeoutInterval = 10.0f;
    [WebOperation webOperationWithRequest:request onComplete:^(WebOperation *operation) {
        NSError *error = nil;
        id result = [NSJSONSerialization JSONObjectWithData:operation.data options:0 error:&error];
        if (error || ![result isKindOfClass:[NSDictionary class]]) {
            if (failureBlock) {
                failureBlock(self,error);
            }
        } else {
            if (successBlock) {
                successBlock(self,result);
            }
        }
    }];
    return self;
}

@end
