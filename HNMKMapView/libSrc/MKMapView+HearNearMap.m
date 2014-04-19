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

//- (void)centerCorrdinate:(CLLocationCoordinate2D)coordinate inRect:(CGRect)bound withDistanceFromCenter:(CLLocationDistance)distance {
//    distance = 1.0;
//    
//    MKCoordinateRegion coordRegion = MKCoordinateRegionMakeWithDistance(coordinate, distance, distance);
//    MKMapRect rect = MKMapRectForCoordinateRegion(coordRegion);
//    
//    CGFloat insetTop = 0;
//    CGFloat insetBottom = self.bounds.size.height - bound.size.height;
//    UIEdgeInsets insets = UIEdgeInsetsMake(insetTop, 0, insetBottom, 0);
//    
//    NSLog(@"Map bound: %@", NSStringFromCGRect(self.bounds));
//    NSLog(@"bound: %@", NSStringFromCGRect(bound));
//    NSLog(@"Inset bottom: %f", insetBottom);
//    
//    MKMapRect rectThatFits = [self mapRectThatFits:rect edgePadding:insets];
//    
//    MKCoordinateRegion region = MKCoordinateRegionForMapRect(rect);
//    NSLog(@"Adjusted region: %@", MKStringFromCoordinateRegion(region));
//    
//    CGRect newRect = [self convertRegion:region toRectToView:self];
//    NSLog(@"Adjusted rect: %@", NSStringFromCGRect(newRect));
//    
//    NSLog(@"top left rect: %@", MKStringFromCoordinate([self convertPoint:newRect.origin toCoordinateFromView:self]));
//    
//    CGPoint pt = CGPointMake(newRect.origin.x + newRect.size.width, newRect.origin.y + newRect.size.height);
//    NSLog(@"bot right rect: %@", MKStringFromCoordinate([self convertPoint:pt toCoordinateFromView:self]));
//
//    [self setVisibleMapRect:rectThatFits edgePadding:insets animated:YES];
//}

@end
