//
//  MyAnnotation.m
//  Map View
//
//  Created by Nina Yang on 9/9/15.
//  Copyright (c) 2015 Nina Yang. All rights reserved.
//

#import "MyAnnotation.h"

@implementation MyAnnotation

-(id)initWithTitle:(NSString *)newTitle location:(CLLocationCoordinate2D)location andURL:(NSString *)urlString {
    self = [super init];
    
    if (self) {
        self.title = newTitle;
        self.coordinate = location;
        self.urlString = urlString;
    }

    return self;
}

@end
