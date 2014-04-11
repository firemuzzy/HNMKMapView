//
//  HNMKMapView.h
//  HNMKMapView
//
//  Created by Michael Charkin on 4/6/14.
//  Copyright (c) 2014 HearNear. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <MBXMapKit.h>
#import "FZMapFoundation.h"

#ifndef HNMapLog
    #if LOG_HN_MAP
        #define HNMapLog(_format_, ...) NSLog(_format_, ## __VA_ARGS__)
    #else
        #define HNMapLog(_format_, ...)
    #endif
#endif

@protocol FZMapViewDelegate <MKMapViewDelegate>

@optional
- (void)mapView:(MKMapView *)mapView didOpenToInitialCamera:(MKMapCamera *)camera;
- (void)tapOnMapView:(MKMapView *)mapView;
- (void)doubleTapOnMapView:(MKMapView *)mapView;
@end

@interface FZMapView : MBXMapView

@property (nonatomic, strong) id<FZMapViewDelegate> fzDelegate;

- (instancetype)initWithFrame:(CGRect)frame mapID:(NSString *)mapID initialCamera:(MKMapCamera *)camera;
- (instancetype)initWithInitialCamera:(MKMapCamera *)camera;

-(CLLocationCoordinate2D) northEast;
-(CLLocationCoordinate2D) southWest;
-(FZSphericalTrapezium) latitudeLongitudeBoundingBox;

@end
