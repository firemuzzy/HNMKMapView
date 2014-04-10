//
//  HNMKMapView.m
//  HNMKMapView
//
//  Created by Michael Charkin on 4/6/14.
//  Copyright (c) 2014 HearNear. All rights reserved.
//

#import "FZMapView.h"
#import "MKMapView+HearNearMap.h"

@interface FZMapView ()<MKMapViewDelegate>

@property (nonatomic, strong) MKMapCamera *initialCamera;

@property (atomic, assign) BOOL didPreformFirstRender;
@property (atomic, assign) BOOL initiatedFirstCameraSet;

@property (atomic, assign) BOOL didPreformOnFirstOpen;

@property (atomic, assign) BOOL lockingOnToCurrentLocation;

@property (atomic, strong) MKUserLocation *lastUserLocation;

@end

@implementation FZMapView

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


- (void)_openedToInitialcamera {
    if([self.fzDelegate respondsToSelector:@selector(mapView:didOpenToInitialCamera:) ]) {
        HNMapLog(@"Opened to initial camera %@", self.initialCamera);
        self.didPreformOnFirstOpen = YES;
        [self.fzDelegate mapView:self didOpenToInitialCamera:self.initialCamera];
    }
    
    self.initialCamera = nil;
}

-(CLLocationCoordinate2D) northEast {
    return CLLocationCoordinate2DMake(self.region.center.latitude + self.region.span.latitudeDelta / 2.0,
                                      self.region.center.longitude + self.region.span.longitudeDelta / 2.0);
}

-(CLLocationCoordinate2D) southWest {
    return CLLocationCoordinate2DMake(self.region.center.latitude - self.region.span.latitudeDelta / 2.0,
                                      self.region.center.longitude - self.region.span.longitudeDelta / 2.0);
}

//
// Proxying MKMapView methods belo
//
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    // drop all region changed events untill the feirs render starts happening, because until then the data is shit
    if(!self.didPreformFirstRender) return;
    
    if(!self.didPreformOnFirstOpen) return;
    
    HNMapLog(@"regionWillChangeAnimated %@ animated:%@", MKStringFromCoordinateRegion(mapView.region), animated ? @"YES" : @"NO");
    if([self.fzDelegate respondsToSelector:@selector(mapView:regionWillChangeAnimated:) ]) {
        [self.fzDelegate mapView:self regionWillChangeAnimated:animated];
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
    if([self.fzDelegate respondsToSelector:@selector(mapView:regionDidChangeAnimated:) ]) {
        [self.fzDelegate mapView:self regionDidChangeAnimated:animated];
    }
}

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView {
    HNMapLog(@"mapViewWillStartLoadingMap %@", MKStringFromCoordinateRegion(mapView.region));
    if([self.fzDelegate respondsToSelector:@selector(mapViewWillStartLoadingMap:)]) {
        [self.fzDelegate mapViewWillStartLoadingMap:mapView];
    }
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
    HNMapLog(@"mapViewDidFinishLoadingMap %@", MKStringFromCoordinateRegion(mapView.region));
    if([self.fzDelegate respondsToSelector:@selector(mapViewDidFinishLoadingMap:)]) {
        [self.fzDelegate mapViewDidFinishLoadingMap:mapView];
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
    if([self.fzDelegate respondsToSelector:@selector(mapViewWillStartRenderingMap:)]) {
        [self.fzDelegate mapViewWillStartRenderingMap:mapView];
    }
}

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered {    
    HNMapLog(@"mapViewDidFinishRenderingMap %@", MKStringFromCoordinateRegion(mapView.region));
    if([self.fzDelegate respondsToSelector:@selector(mapViewDidFinishRenderingMap:fullyRendered:)]) {
        [self.fzDelegate mapViewDidFinishRenderingMap:mapView fullyRendered:fullyRendered];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    if([self.fzDelegate respondsToSelector:@selector(mapView:viewForAnnotation:)]) {
        return [self.fzDelegate mapView:mapView viewForAnnotation:annotation];
    } else {
        return nil;
    }
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    if([self.fzDelegate respondsToSelector:@selector(mapView:didAddAnnotationViews:)]) {
        [self.fzDelegate mapView:mapView didAddAnnotationViews:views];
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if([self.fzDelegate respondsToSelector:@selector(mapView:didSelectAnnotationView:)]) {
        [self.fzDelegate mapView:mapView didSelectAnnotationView:view];
    }
}
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if([self.fzDelegate respondsToSelector:@selector(mapView:didDeselectAnnotationView:)]) {
        [self.fzDelegate mapView:mapView didDeselectAnnotationView:view];
    }
}


- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView {
    HNMapLog(@"mapViewWillStartLocatingUser");
    if([self.fzDelegate respondsToSelector:@selector(mapViewWillStartLocatingUser:)]) {
        [self.fzDelegate mapViewWillStartLocatingUser:mapView];
    }
}
- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView {
    HNMapLog(@"mapViewDidStopLocatingUser");
    if([self.fzDelegate respondsToSelector:@selector(mapViewDidStopLocatingUser:)]) {
        [self.fzDelegate mapViewDidStopLocatingUser:mapView];
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    HNMapLog(@"didUpdateUserLocation: %@", userLocation.location);
    
    self.lastUserLocation = userLocation;
    
    if([self.fzDelegate respondsToSelector:@selector(mapView:didUpdateUserLocation:)]) {
        [self.fzDelegate mapView:mapView didUpdateUserLocation:userLocation];
    }
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    HNMapLog(@"didFailToLocateUserWithError: %@", error);

    if([self.fzDelegate respondsToSelector:@selector(mapView:didFailToLocateUserWithError:)]) {
        [self.fzDelegate mapView:mapView didFailToLocateUserWithError:error];
    }
}

- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated {
    if([self.fzDelegate respondsToSelector:@selector(mapView:didChangeUserTrackingMode:animated:)]) {
        [self.fzDelegate mapView:mapView didChangeUserTrackingMode:mode animated:animated];
    }
}

@end