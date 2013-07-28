//
//  WebOperation.m
//  microclimate
//
//  Created by Robert Diamond on 7/27/13.
//  Copyright (c) 2013 Robert Diamond. All rights reserved.
//

#import "WebOperation.h"

@interface WebOperation () <NSURLConnectionDataDelegate>

@property (nonatomic) NSURLConnection *connection;
@property (nonatomic,copy) CompletionBlock completionBlock;
@property (nonatomic) NSOperationQueue *fetchQueue;
@property (nonatomic) NSError *error;
@property (nonatomic) NSURLResponse *response;
@property (nonatomic) NSData *data;
@property (nonatomic) BOOL isFinished;
@end

@implementation WebOperation

+ (WebOperation *)webOperationWithRequest:(NSURLRequest *)request onComplete:(CompletionBlock)completionBlock
{
    return [[self new] initWithRequest:request onComplete:completionBlock];
}

- (id)initWithRequest:(NSURLRequest *)request onComplete:(CompletionBlock)completionBlock
{
    self = [self init];
    if (self) {
        self.completionBlock = completionBlock;
        __weak WebOperation *weakSelf = self;
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *resp, NSData *data, NSError *err) {
            WebOperation *strongSelf = weakSelf;
            if (strongSelf) {
                _error = err;
                _data = data;
                _response = resp;
                _isFinished = YES;
                if (completionBlock) {
                    completionBlock(strongSelf);
                }
            }
        }];
    }
    return self;
}

@end
