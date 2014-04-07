//
//  MKMapView+HearNearMap.h
//  HNMKMapView
//
//  Created by Michael Charkin on 4/6/14.
//  Copyright (c) 2014 HearNear. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (HearNearMap)

NSString *MKStringFromCoordinate(CLLocationCoordinate2D coordinate);

NSString *MKStringCoordinateSpan(MKCoordinateSpan span);

NSString *MKStringFromCoordinateRegion(MKCoordinateRegion coordinateRegion);

BOOL MKMapCamerasEqual(MKMapCamera *cam1, MKMapCamera *cam2);

BOOL CLLocationAreCoordinatesEqual(CLLocationCoordinate2D coord1, CLLocationCoordinate2D coord2, CLLocationDegrees threshold);

CLLocationCoordinate2D CLLocationCoordinateMovedSouthMake(CLLocationCoordinate2D coord, CLLocationDistance meters);

MKMapRect MKMapRectForCoordinateRegion(MKCoordinateRegion region);


-(CLLocationCoordinate2D) northEast;
-(CLLocationCoordinate2D) southWest;

- (void)zoomMapViewToFitAnnotationsWithExtraZoomToAdjust:(double)extraZoom;

-(CLLocationCoordinate2D) getCenterCoordinateinRect:(CGRect) rect;

- (void)panDownByPixels:(CGFloat)pixels;
- (MKMapCamera *) cameraOverCoordinate:(CLLocationCoordinate2D)coordinate inRect:(CGRect)bound withEyeAltitude:(CLLocationDistance)altitude;

@end
