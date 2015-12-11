//
//  MyAnnotation.h
//  Map View
//
//  Created by Nina Yang on 9/9/15.
//  Copyright (c) 2015 Nina Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MyAnnotation : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSString *urlString;

-(id)initWithTitle:(NSString *)newTitle location:(CLLocationCoordinate2D)location andURL:(NSString *)urlString;

@end
