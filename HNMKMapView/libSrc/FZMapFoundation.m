//
//  FZMapFoundation.m
//  FZMapKit
//
//  Created by Michael Charkin on 4/9/14.
//  Copyright (c) 2014 HearNear. All rights reserved.
//

#import "FZMapFoundation.h"

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


FZSphericalTrapezium FZSphericalTrapeziumMake(CLLocationCoordinate2D southwest, CLLocationCoordinate2D northeast) {
    FZSphericalTrapezium trap;
    trap.southWest = southwest;
    trap.northEast = northeast;
    return trap;
}

@implementation FZMapFoundation

@end
