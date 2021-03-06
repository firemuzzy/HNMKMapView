//
//  HNMKMapView.m
//  HNMKMapView
//
//  Created by Michael Charkin on 4/6/14.
//  Copyright (c) 2014 HearNear. All rights reserved.
//

#import "FZMapView.h"
#import "MKMapView+HearNearMap.h"

@interface FZMapView ()<MKMapViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSTimer *deselectTimer;

//@property (atomic, assign) BOOL didPreformFirstRender;
//@property (atomic, assign) BOOL initiatedFirstCameraSet;

//@property (atomic, assign) BOOL didPreformOnFirstOpen;

//@property (atomic, assign) BOOL lockingOnToCurrentLocation;

@property (atomic, strong) MKUserLocation *lastUserLocation;
@property (nonatomic, strong) UITapGestureRecognizer *tapOnMapRecognizer;
//@property (nonatomic, strong) UITapGestureRecognizer *doubleTapOnMapRecognizer;
@end

@implementation FZMapView

- (instancetype) init {
    if(self = [super init]) {
        __typeof__(self) __weak weakSelf = self;
        self.delegate = weakSelf;
        [self addGestureRecognizer:self.tapOnMapRecognizer];
    }
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        __typeof__(self) __weak weakSelf = self;
        self.delegate = weakSelf;
        [self addGestureRecognizer:self.tapOnMapRecognizer];
    }
    return self;
}


//-(UITapGestureRecognizer *) doubleTapOnMapRecognizer {
//    if(_doubleTapOnMapRecognizer) return _doubleTapOnMapRecognizer;
//    _doubleTapOnMapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapOnMapView:)];
//    _doubleTapOnMapRecognizer.numberOfTapsRequired = 2;
//    _doubleTapOnMapRecognizer.delegate = self;
//    return _doubleTapOnMapRecognizer;
//}

-(void) doubleTapOnMapView: (UITapGestureRecognizer *) doubleTapOnMapRecognizer {
    CGPoint p = [doubleTapOnMapRecognizer locationInView:self];
    UIView *v = [self hitTest:p withEvent:nil];
    
    if(![v isKindOfClass:[MKAnnotationView class]]) {
        if([self.fzDelegate respondsToSelector:@selector(doubleTapOnMapView:) ]) {
            [self.fzDelegate doubleTapOnMapView:self];
        }
    }
}


-(UITapGestureRecognizer *) tapOnMapRecognizer {
    if(_tapOnMapRecognizer) return _tapOnMapRecognizer;
    _tapOnMapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnMapView:)];
//    [_tapOnMapRecognizer requireGestureRecognizerToFail:self.doubleTapOnMapRecognizer];
    _tapOnMapRecognizer.delegate = self;
    return _tapOnMapRecognizer;
}

-(void) tapOnMapView: (UITapGestureRecognizer *) tapOnMapRecognizer {
    CGPoint p = [tapOnMapRecognizer locationInView:self];
    UIView *v = [self hitTest:p withEvent:nil];
    
    if(![v isKindOfClass:[MKAnnotationView class]]) {
        if([self.fzDelegate respondsToSelector:@selector(tapOnMapView:atPoint:) ]) {
            [self.fzDelegate tapOnMapView:self atPoint:p];
        }
    }
}

-(CLLocationCoordinate2D) northEast {
    CLLocationDegrees lat = self.region.center.latitude + self.region.span.latitudeDelta / 2.0;
    CLLocationDegrees peggedLat;
    peggedLat = MIN(85, lat);
    peggedLat = MAX(-85, peggedLat);
    
    CLLocationDegrees lng = self.region.center.longitude + self.region.span.longitudeDelta / 2.0;
    CLLocationDegrees peggedLng;
    peggedLng = MAX(-180, lng);
    peggedLng = MIN(180, peggedLng);
    
    return CLLocationCoordinate2DMake(peggedLat, peggedLng);
}

-(CLLocationCoordinate2D) southWest {
    CLLocationDegrees lat = self.region.center.latitude - self.region.span.latitudeDelta / 2.0;
    CLLocationDegrees peggedLat;
    peggedLat = MIN(85, lat);
    peggedLat = MAX(-85, peggedLat);
    
    CLLocationDegrees lng = self.region.center.longitude - self.region.span.longitudeDelta / 2.0;
    CLLocationDegrees peggedLng;
    peggedLng = MAX(-180, lng);
    peggedLng = MIN(180, peggedLng);
    
    return CLLocationCoordinate2DMake(peggedLat, peggedLng);
}

-(FZSphericalTrapezium) latitudeLongitudeBoundingBox {
    return FZSphericalTrapeziumMake(self.southWest, self.northEast);
}

-(void)addMappables:(NSArray *)mappables withCurrentlySelected:(id<FZMapable>)currentlySelected {
    MKAnnotationView *userLocationView;
    
    //    __block NSArray *annotations;
    //    dispatch_sync(dispatch_get_main_queue(), ^{
    //        annotations = self.annotations;
    //    });
    NSArray *annotations = self.annotations;
    NSUInteger annotationsCount = annotations.count;
    
    
    
    NSMutableDictionary *byId = [[NSMutableDictionary alloc] initWithCapacity:mappables.count];
    for(id<FZMapable> mappable in mappables) {
        NSParameterAssert(mappable);
        NSParameterAssert(mappable._id);
        [byId setObject:mappable forKey:mappable._id];
    }
    
    NSMutableArray *mappablesToRemove = [[NSMutableArray alloc] initWithCapacity:annotationsCount];
    NSMutableArray *viewsAnnotationsToRemove = [[NSMutableArray alloc] initWithCapacity:annotationsCount];
    [annotations enumerateObjectsUsingBlock:^(id<FZMapable> mappable, NSUInteger idx, BOOL *stop) {
        NSParameterAssert(mappable);
        if([mappable isKindOfClass:[MKUserLocation class]]) return;
        
        if([mappable conformsToProtocol:@protocol(FZMapable)]) {
            if(![byId objectForKey:mappable._id] && ![currentlySelected._id isEqualToString:mappable._id] ) {
                [mappablesToRemove addObject:mappable];
                UIView *annotationView = [self viewForAnnotation:mappable];
                if(annotationView) [viewsAnnotationsToRemove addObject:annotationView];
            }
        }
    }];
    
    NSMutableDictionary *visibleById = [[NSMutableDictionary alloc] initWithCapacity:annotationsCount];
    for(id<FZMapable> mappable in annotations) {
        if([mappable isKindOfClass:[MKUserLocation class]]) {
            userLocationView = [self viewForAnnotation:mappable];
            continue;
        }
        else if([mappable conformsToProtocol:@protocol(FZMapable)]) {
            NSParameterAssert(mappable);
            NSParameterAssert(mappable._id);
            [visibleById setObject:mappable forKey:mappable._id];
        }
    }
    
    NSMutableSet *newAnnotations = [[NSMutableSet alloc] initWithCapacity:mappables.count];
    if(mappables) {
        for(id<FZMapable>newMappable in mappables) {
            id<FZMapable>visibleMappable = [visibleById objectForKey:newMappable._id];
            if(!visibleMappable) {
                [newAnnotations addObject:newMappable];
            }
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSParameterAssert(newAnnotations);
        [self addAnnotations:[newAnnotations allObjects]];
        [UIView animateWithDuration:.5f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            for(UIView *view in viewsAnnotationsToRemove) {
                view.alpha = 0.f;
            }
        } completion:^(BOOL finished) {
            [self removeAnnotations:mappablesToRemove];
            [userLocationView.superview bringSubviewToFront:userLocationView];
        }];
    });
}

//
// Proxying MKMapView methods belo
//
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    // drop all region changed events untill the feirs render starts happening, because until then the data is shit
//    if(!self.didPreformFirstRender) return;
    
//    if(!self.didPreformOnFirstOpen) return;
    
    HNMapLog(@"regionWillChangeAnimated %@ animated:%@", MKStringFromCoordinateRegion(mapView.region), animated ? @"YES" : @"NO");
    if([self.fzDelegate respondsToSelector:@selector(mapView:regionWillChangeAnimated:) ]) {
        [self.fzDelegate mapView:self regionWillChangeAnimated:animated];
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    // drop all region changed events untill the feirs render starts happening, because until then the data is shit
//    if(!self.didPreformFirstRender) return;
    
//    if(self.initialCamera && self.initiatedFirstCameraSet && MKMapCamerasEqual(self.camera, self.initialCamera)) {
//        [self _openedToInitialcamera];
//        return;
//    }
    
//    if(!self.didPreformOnFirstOpen) return;
    
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

//Magic comes below
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
//    NSLog(@"SELECT");
    [self.deselectTimer invalidate];
    if([self.fzDelegate respondsToSelector:@selector(mapView:didSelectAnnotationView:)]) {
        [self.fzDelegate mapView:mapView didSelectAnnotationView:view];
    }
}
-(void)deselectTimerCalled:(NSTimer *) timer {
    if(![self.deselectTimer isValid]) return;
    NSDictionary *userInfo = timer.userInfo;
    [self.deselectTimer invalidate];
//    NSLog(@"DESELECT");
    [self mapView:self didDeselectAfterTimerAnnotationView:userInfo[@"view"]];
}

- (void)mapView:(MKMapView *)mapView didDeselectAfterTimerAnnotationView:(MKAnnotationView *)view {
    if([self.fzDelegate respondsToSelector:@selector(mapView:didDeselectAfterTimerAnnotationView:)]) {
        [self.fzDelegate mapView:mapView didDeselectAfterTimerAnnotationView:view];
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    [self.deselectTimer invalidate];
    self.deselectTimer = [NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(deselectTimerCalled:) userInfo:@{@"view":view?view:[NSNull null]} repeats:NO];
    if([self.fzDelegate respondsToSelector:@selector(mapView:didDeselectAnnotationView:)]) {
        [self.fzDelegate mapView:mapView didDeselectAnnotationView:view];
    }
}
//Magic ends


-(MKOverlayRenderer *) mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if([self.fzDelegate respondsToSelector:@selector(mapView:rendererForOverlay:)]) {
        return [self.fzDelegate mapView:mapView rendererForOverlay:overlay];
    } else {
        return nil;
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

#pragma mark UIGestureRecognizerDelegate
-(BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
@end
