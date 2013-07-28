//
//  WeatherAPI.h
//  microclimate
//
//  Created by Robert Diamond on 7/27/13.
//  Copyright (c) 2013 Robert Diamond. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ArrayCompletion)(id fetcher, NSArray *);
typedef void (^DictionaryCompletion)(id fetcher, NSDictionary *);
typedef void (^ErrorCompletion)(id fetcher, NSError *);

@class WeatherMapAnnotation;
@interface WeatherAPI : NSObject

+ (id)fetchStationsNearLatitude:(double)lat longitude:(double)lon withCompletionBlock:(ArrayCompletion)successBlock failureBlock:(ErrorCompletion)failureBlock;
+ (id)fetchConditionsForStation:(WeatherMapAnnotation *)station withCompletionBlock:(DictionaryCompletion)successBlock failureBlock:(ErrorCompletion)failureBlock;

@end
