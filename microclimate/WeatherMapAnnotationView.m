//
//  WeatherMapAnnotationView.m
//  microclimate
//
//  Created by Robert Diamond on 7/28/13.
//  Copyright (c) 2013 Robert Diamond. All rights reserved.
//

#import "WeatherConditions.h"
#import "WeatherMapAnnotationView.h"
#import "WeatherMapAnnotation.h"

@interface WeatherMapAnnotationView ()

@property (nonatomic) UILabel *temp;
@property (nonatomic) NSString *unit;

@end

@implementation WeatherMapAnnotationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _temp = [[UILabel alloc] initWithFrame:frame];
        _temp.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];
        _temp.textColor = [UIColor blackColor];
        _temp.opaque = NO;
        _temp.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
        [self addSubview:_temp];
        if ([[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem] boolValue] == YES) {
            _unit = @"C";
        } else {
            _unit = @"F";
        }
    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    WeatherMapAnnotation *annotation = self.annotation;
    if (annotation.conditions) {
        float temp = annotation.conditions.temp_c;
        if ([_unit isEqualToString:@"F"]) {
            temp = temp * 9.0 / 5.0 + 32.0;
        }
        _temp.text = [NSString stringWithFormat:@"%.1fº%@", temp, _unit];
        [_temp sizeToFit];
    }
}
@end
