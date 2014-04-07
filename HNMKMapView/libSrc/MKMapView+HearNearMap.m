//
//  MKMapView+HearNearMap.m
//  HNMKMapView
//
//  Created by Michael Charkin on 4/6/14.
//  Copyright (c) 2014 HearNear. All rights reserved.
//

#import "MKMapView+HearNearMap.h"
#import <CoreLocation/CoreLocation.h>

@implementation MKMapView (HearNearMap)

-(CLLocationCoordinate2D) northEast {    
    return CLLocationCoordinate2DMake(self.region.center.latitude + self.region.span.latitudeDelta / 2.0,
                                      self.region.center.longitude + self.region.span.longitudeDelta / 2.0);
}

-(CLLocationCoordinate2D) southWest {
    return CLLocationCoordinate2DMake(self.region.center.latitude - self.region.span.latitudeDelta / 2.0,
                                      self.region.center.longitude - self.region.span.longitudeDelta / 2.0);
}

NSString *MKStringFromCoordinate(CLLocationCoordinate2D coordinate) {
    return [NSString stringWithFormat:@"{%.6f, %.6f}", coordinate.latitude, coordinate.longitude];
}

NSString *MKStringCoordinateSpan(MKCoordinateSpan span) {
    return [NSString stringWithFormat:@"{%.6f, %.6f}", span.latitudeDelta, span.longitudeDelta];
}

NSString *MKStringFromCoordinateRegion(MKCoordinateRegion coordinateRegion) {
    return [NSString stringWithFormat:@"{%@, %@}", MKStringFromCoordinate(coordinateRegion.center), MKStringCoordinateSpan(coordinateRegion.span)];
}

BOOL MKMapCamerasEqual(MKMapCamera *cam1, MKMapCamera *cam2){
    return CLLocationAreCoordinatesEqual(cam1.centerCoordinate, cam2.centerCoordinate, 0.000001) &&
    ABS(cam1.altitude - cam2.altitude) < 0.1;
}

BOOL CLLocationAreCoordinatesEqual(CLLocationCoordinate2D coord1, CLLocationCoordinate2D coord2, CLLocationDegrees threshold){
    return (ABS(coord1.latitude - coord2.latitude) <= threshold) && (ABS(coord1.longitude - coord2.longitude <= threshold));
}

CLLocationCoordinate2D CLLocationCoordinateMovedSouthMake(CLLocationCoordinate2D coord, CLLocationDistance meters) {
    double mapPointsToMoveBy = MKMapPointsPerMeterAtLatitude(coord.latitude) * meters;
    
    MKMapPoint coordAsPoint = MKMapPointForCoordinate(coord);
    // move the point south
    coordAsPoint.y += mapPointsToMoveBy;
    
    CLLocationCoordinate2D movedCoordinate = MKCoordinateForMapPoint(coordAsPoint);
    return movedCoordinate;
}

MKMapRect MKMapRectForCoordinateRegion(MKCoordinateRegion region)
{
    MKMapPoint a = MKMapPointForCoordinate(CLLocationCoordinate2DMake(
                                                                      region.center.latitude + region.span.latitudeDelta / 2,
                                                                      region.center.longitude - region.span.longitudeDelta / 2));
    MKMapPoint b = MKMapPointForCoordinate(CLLocationCoordinate2DMake(
                                                                      region.center.latitude - region.span.latitudeDelta / 2,
                                                                      region.center.longitude + region.span.longitudeDelta / 2));
    return MKMapRectMake(MIN(a.x,b.x), MIN(a.y,b.y), ABS(a.x-b.x), ABS(a.y-b.y));
}


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

/*
 * DANGER: this is a hack, only use it to center on the point when opening a detail page, do not use to center map when begin editing
 * do not use in cases where you need the map position to be exact
 *
 */
#define IOS_MAP_CAMERA_APERTURE (14.0/180.0 * M_PI)
- (MKMapCamera *) cameraOverCoordinate:(CLLocationCoordinate2D)coordinate inRect:(CGRect)bound withEyeAltitude:(CLLocationDistance)altitude {
    if(CGRectEqualToRect(bound, CGRectZero)) return nil;
    
    NSLog(@"Map Bounds: %@", NSStringFromCGRect(self.bounds));
    NSLog(@"Provided bound: %@", NSStringFromCGRect(bound));
    
    
    CLLocationDistance verticalOffsetForCenter;
    verticalOffsetForCenter = (altitude * tan(IOS_MAP_CAMERA_APERTURE) / bound.size.height) * (self.bounds.size.height);
    NSLog(@"verticalOffsetForCenter: %f", verticalOffsetForCenter);
    
    CLLocationCoordinate2D offsetCenter = CLLocationCoordinateMovedSouthMake(coordinate, verticalOffsetForCenter);
    NSLog(@"offsetCenter: (%f,%f)", offsetCenter.latitude, offsetCenter.longitude);
    
    CLLocationDistance offsetAltitude = (altitude * ((double)self.bounds.size.height)) / ((double)bound.size.height);
    
    MKMapCamera *camera = [MKMapCamera cameraLookingAtCenterCoordinate:offsetCenter fromEyeCoordinate:offsetCenter eyeAltitude:offsetAltitude];
    return camera;
}

@end
