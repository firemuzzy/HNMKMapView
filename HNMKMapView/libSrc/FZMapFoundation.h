//
//  FZMapFoundation.h
//  FZMapKit
//
//  Created by Michael Charkin on 4/9/14.
//  Copyright (c) 2014 HearNear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

typedef struct {
	CLLocationCoordinate2D southWest;
	CLLocationCoordinate2D northEast;
} FZSphericalTrapezium;

FZSphericalTrapezium FZSphericalTrapeziumMake(CLLocationCoordinate2D southwest, CLLocationCoordinate2D northeast);

NSString *MKStringFromCoordinate(CLLocationCoordinate2D coordinate);

NSString *MKStringCoordinateSpan(MKCoordinateSpan span);

NSString *MKStringFromCoordinateRegion(MKCoordinateRegion coordinateRegion);

BOOL MKMapCamerasEqual(MKMapCamera *cam1, MKMapCamera *cam2);

BOOL CLLocationAreCoordinatesEqual(CLLocationCoordinate2D coord1, CLLocationCoordinate2D coord2, CLLocationDegrees threshold);

CLLocationCoordinate2D CLLocationCoordinateMovedSouthMake(CLLocationCoordinate2D coord, CLLocationDistance meters);

MKMapRect MKMapRectForCoordinateRegion(MKCoordinateRegion region);

@interface FZMapFoundation : NSObject

@end
