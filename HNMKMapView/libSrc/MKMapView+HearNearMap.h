//
//  MKMapView+HearNearMap.h
//  HNMKMapView
//
//  Created by Michael Charkin on 4/6/14.
//  Copyright (c) 2014 HearNear. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "FZMapFoundation.h"

@interface MKMapView (HearNearMap)

- (void)zoomMapViewToFitAnnotationsWithExtraZoomToAdjust:(double)extraZoom;

-(CLLocationCoordinate2D) getCenterCoordinateinRect:(CGRect) rect;

- (void)panDownByPixels:(CGFloat)pixels;

//- (void)centerCorrdinate:(CLLocationCoordinate2D)coordinate inRect:(CGRect)bound withDistanceFromCenter:(CLLocationDistance)distance;

@end
