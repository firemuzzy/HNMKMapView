//
//  HNMKMapView.m
//  HNMKMapView
//
//  Created by Michael Charkin on 4/6/14.
//  Copyright (c) 2014 HearNear. All rights reserved.
//

#import "HNMKMapView.h"
#import "MKMapView+HearNearMap.h"

@interface HNMKMapView ()<MKMapViewDelegate>

@property (nonatomic, strong) MKMapCamera *initialCamera;

@property (atomic, assign) BOOL didPreformFirstRender;
@property (atomic, assign) BOOL initiatedFirstCameraSet;

@property (atomic, assign) BOOL didPreformOnFirstOpen;

@property (atomic, assign) BOOL lockingOnToCurrentLocation;

@property (atomic, strong) MKUserLocation *lastUserLocation;

@end

@implementation HNMKMapView

- (id)initWithInitialCamera:(MKMapCamera *)camera
{
    self = [super init];
    if (self) {
        self.delegate = self;
        _initialCamera = camera;
        
        HNMapLog(@"Set initial camera variable to %@", camera);

        // Initialization code
    }
    return self;
}

- (void)setHNDelegate:(id<HNMKMapViewDelegate>)delegate {
    _hnDelegate = delegate;
}


- (void)_openedToInitialcamera {
    if([self.hnDelegate respondsToSelector:@selector(mapView:didOpenToInitialCamera:) ]) {
        HNMapLog(@"Opened to initial camera %@", self.initialCamera);
        self.didPreformOnFirstOpen = YES;
        [self.hnDelegate mapView:self didOpenToInitialCamera:self.initialCamera];
    }
    
    self.initialCamera = nil;
}

//
// Proxying MKMapView methods belo
//
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    // drop all region changed events untill the feirs render starts happening, because until then the data is shit
    if(!self.didPreformFirstRender) return;
    
    if(!self.didPreformOnFirstOpen) return;
    
    HNMapLog(@"regionWillChangeAnimated %@ animated:%@", MKStringFromCoordinateRegion(mapView.region), animated ? @"YES" : @"NO");
    if([self.hnDelegate respondsToSelector:@selector(mapView:regionWillChangeAnimated:) ]) {
        [self.hnDelegate mapView:self regionWillChangeAnimated:animated];
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    // drop all region changed events untill the feirs render starts happening, because until then the data is shit
    if(!self.didPreformFirstRender) return;
    
    if(self.initialCamera && self.initiatedFirstCameraSet && MKMapCamerasEqual(self.camera, self.initialCamera)) {
        [self _openedToInitialcamera];
        return;
    }
    
    if(!self.didPreformOnFirstOpen) return;
    
    HNMapLog(@"regionDidChangeAnimated %@ animated:%@", MKStringFromCoordinateRegion(mapView.region), animated ? @"YES" : @"NO");
    if([self.hnDelegate respondsToSelector:@selector(mapView:regionDidChangeAnimated:) ]) {
        [self.hnDelegate mapView:self regionDidChangeAnimated:animated];
    }
}

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView {
    HNMapLog(@"mapViewWillStartLoadingMap %@", MKStringFromCoordinateRegion(mapView.region));
    if([self.hnDelegate respondsToSelector:@selector(mapViewWillStartLoadingMap:)]) {
        [self.hnDelegate mapViewWillStartLoadingMap:mapView];
    }
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
    HNMapLog(@"mapViewDidFinishLoadingMap %@", MKStringFromCoordinateRegion(mapView.region));
    if([self.hnDelegate respondsToSelector:@selector(mapViewDidFinishLoadingMap:)]) {
        [self.hnDelegate mapViewDidFinishLoadingMap:mapView];
    }
}

- (void)mapViewWillStartRenderingMap:(MKMapView *)mapView {
    if(!self.didPreformFirstRender) {
        HNMapLog(@"Preformed fierst render");
        self.didPreformFirstRender = YES;
    }
    
    if(!self.initiatedFirstCameraSet) {
        self.initiatedFirstCameraSet = YES;

        if(self.initialCamera) {
            [self setCamera:self.initialCamera animated:NO];
        } else {
            [self _openedToInitialcamera];
        }
    }
    
    HNMapLog(@"mapViewWillStartRenderingMap %@", MKStringFromCoordinateRegion(mapView.region));
    if([self.hnDelegate respondsToSelector:@selector(mapViewWillStartRenderingMap:)]) {
        [self.hnDelegate mapViewWillStartRenderingMap:mapView];
    }
}

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered {    
    HNMapLog(@"mapViewDidFinishRenderingMap %@", MKStringFromCoordinateRegion(mapView.region));
    if([self.hnDelegate respondsToSelector:@selector(mapViewDidFinishRenderingMap:fullyRendered:)]) {
        [self.hnDelegate mapViewDidFinishRenderingMap:mapView fullyRendered:fullyRendered];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    if([self.hnDelegate respondsToSelector:@selector(mapView:viewForAnnotation:)]) {
        return [self.hnDelegate mapView:mapView viewForAnnotation:annotation];
    } else {
        return nil;
    }
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    if([self.hnDelegate respondsToSelector:@selector(mapView:didAddAnnotationViews:)]) {
        [self.hnDelegate mapView:mapView didAddAnnotationViews:views];
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if([self.hnDelegate respondsToSelector:@selector(mapView:didSelectAnnotationView:)]) {
        [self.hnDelegate mapView:mapView didSelectAnnotationView:view];
    }
}
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if([self.hnDelegate respondsToSelector:@selector(mapView:didDeselectAnnotationView:)]) {
        [self.hnDelegate mapView:mapView didDeselectAnnotationView:view];
    }
}


- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView {
    HNMapLog(@"mapViewWillStartLocatingUser");
    if([self.hnDelegate respondsToSelector:@selector(mapViewWillStartLocatingUser:)]) {
        [self.hnDelegate mapViewWillStartLocatingUser:mapView];
    }
}
- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView {
    HNMapLog(@"mapViewDidStopLocatingUser");
    if([self.hnDelegate respondsToSelector:@selector(mapViewDidStopLocatingUser:)]) {
        [self.hnDelegate mapViewDidStopLocatingUser:mapView];
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    HNMapLog(@"didUpdateUserLocation: %@", userLocation.location);
    
    self.lastUserLocation = userLocation;
    
    if([self.hnDelegate respondsToSelector:@selector(mapView:didUpdateUserLocation:)]) {
        [self.hnDelegate mapView:mapView didUpdateUserLocation:userLocation];
    }
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    HNMapLog(@"didFailToLocateUserWithError: %@", error);

    if([self.hnDelegate respondsToSelector:@selector(mapView:didFailToLocateUserWithError:)]) {
        [self.hnDelegate mapView:mapView didFailToLocateUserWithError:error];
    }
}

- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated {
    if([self.hnDelegate respondsToSelector:@selector(mapView:didChangeUserTrackingMode:animated:)]) {
        [self.hnDelegate mapView:mapView didChangeUserTrackingMode:mode animated:animated];
    }
}

@end
