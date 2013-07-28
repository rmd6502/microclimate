//
//  WeatherAPI.h
//  microclimate
//
//  Created by Robert Diamond on 7/27/13.
//  Copyright (c) 2013 Robert Diamond. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ArrayCompletion)(NSArray *);
typedef void (^DictionaryCompletion)(NSDictionary *);
typedef void (^ErrorCompletion)(NSError *);

@class WeatherMapAnnotation;
@interface WeatherAPI : NSObject

+ (void)fetchStationsNearLatitude:(double)lat longitude:(double)lon withCompletionBlock:(ArrayCompletion)successBlock failureBlock:(ErrorCompletion)failureBlock;
+ (void)fetchConditionsForStation:(WeatherMapAnnotation *)station withCompletionBlock:(DictionaryCompletion)successBlock failureBlock:(ErrorCompletion)failureBlock;

@end
