//
//  WebOperation.h
//  microclimate
//
//  Created by Robert Diamond on 7/27/13.
//  Copyright (c) 2013 Robert Diamond. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WebOperation;
typedef void(^CompletionBlock)(WebOperation *operation);

@interface WebOperation : NSObject
@property (nonatomic,readonly) NSError *error;
@property (nonatomic,readonly) NSURLResponse *response;
@property (nonatomic,readonly) NSData *data;
@property (nonatomic,readonly) BOOL isFinished;

+ (WebOperation *) webOperationWithRequest:(NSURLRequest *)request onComplete:(CompletionBlock)completionBlock;

- (id)initWithRequest:(NSURLRequest *)request onComplete:(CompletionBlock)completionBlock;
@end
