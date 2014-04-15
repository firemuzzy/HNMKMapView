//
//  MKMapView+HearNearMap.m
//  HNMKMapView
//
//  Created by Michael Charkin on 4/6/14.
//  Copyright (c) 2014 HearNear. All rights reserved.
//

#import "MKMapView+HearNearMap.h"
#import <CoreLocation/CoreLocation.h>

@implementation MKMapView (FZMovement)

- (void)zoomMapViewToFitAnnotationsWithExtraZoomToAdjust:(double)extraZoom {
    if ([self.annotations count] == 0) return;
    
    int i = 0;
    MKMapPoint points[[self.annotations count]];
    
    for (id<MKAnnotation> annotation in [self annotations])
    {
        points[i++] = MKMapPointForCoordinate(annotation.coordinate);
    }
    
    MKPolygon *poly = [MKPolygon polygonWithPoints:points count:i];
    
    MKCoordinateRegion r = MKCoordinateRegionForMapRect([poly boundingMapRect]);
    r.span.latitudeDelta += extraZoom;
    r.span.longitudeDelta += extraZoom;
    
    [self setRegion: r animated:YES];
}

-(CLLocationCoordinate2D) getCenterCoordinateinRect:(CGRect) rect {
    if(CGRectEqualToRect(rect, CGRectZero)) return kCLLocationCoordinate2DInvalid;
    
    CGPoint point = CGPointMake(rect.origin.x + rect.size.width/2, rect.origin.y + rect.size.height/2);
    return [self convertPoint: point toCoordinateFromView:self];
}

- (void)panDownByPixels:(CGFloat)pixels {
    CLLocationCoordinate2D centerCoord = [self centerCoordinate];
    CGPoint pointCenter = [self convertCoordinate:centerCoord toPointToView:self];
    
    CGPoint newCenter = CGPointMake(pointCenter.x, pointCenter.y - pixels);
    CLLocationCoordinate2D newCenterCoord = [self convertPoint:newCenter toCoordinateFromView:self];
    
    NSLog(@"Panning down: %fpt OldCenter:%@ (%.6f,%.6f) NewCenter: %@ (%.6f,%.6f)", pixels, NSStringFromCGPoint(pointCenter),centerCoord.latitude, centerCoord.longitude, NSStringFromCGPoint(newCenter), newCenterCoord.latitude, newCenterCoord.longitude);
    
    [self setCenterCoordinate:newCenterCoord animated:YES];
}

- (void)centerCorrdinate:(CLLocationCoordinate2D)coordinate inRect:(CGRect)bound withDistanceFromCenter:(CLLocationDistance)distance {
    MKCoordinateRegion coordRegion = MKCoordinateRegionMakeWithDistance(coordinate, distance, distance);
    MKMapRect rect = MKMapRectForCoordinateRegion(coordRegion);
    
    CGFloat insetBottom = self.bounds.size.height - bound.size.height;
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, insetBottom, 0);
    
    [self setVisibleMapRect:rect edgePadding:insets animated:YES];
}

@end
