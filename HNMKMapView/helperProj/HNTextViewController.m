//
//  HNTextViewController.m
//  HNMKMapView
//
//  Created by Michael Charkin on 4/6/14.
//  Copyright (c) 2014 HearNear. All rights reserved.
//

#import "HNTextViewController.h"
#import <MapKit/MapKit.h>
#import "FZMapView.h"
#import <CoreLocation/CoreLocation.h>

@interface HNTextViewController ()<FZMapViewDelegate>

@property (nonatomic, strong) FZMapView *mapView;

@property (nonatomic, strong) NSTimer *mapStartTimer;

@end

@implementation HNTextViewController

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    [self.view addConstraints: @[[NSLayoutConstraint constraintWithItem:self.mapView
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1.f
                                                               constant:0.f],
                                 [NSLayoutConstraint constraintWithItem:self.mapView
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.f
                                                               constant:0.f],
                                 [NSLayoutConstraint constraintWithItem:self.mapView
                                                              attribute:NSLayoutAttributeLeading
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeLeading
                                                             multiplier:1.f
                                                               constant:0.f],
                                 [NSLayoutConstraint constraintWithItem:self.mapView
                                                              attribute:NSLayoutAttributeTrailing
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeTrailing
                                                             multiplier:1.f
                                                               constant:0.f]
     ]];
    
}


-(void)start {
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow];
}

- (void) mapView:(MKMapView *)mapView didOpenToInitialCamera:(MKMapCamera *)camera {
    NSLog(@"Opened to initial camera");
}

- (MKMapView *)mapView {
    if(_mapView) return _mapView;
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(37.660258, -122.432493);
//    MKMapCamera *camera = [MKMapCamera cameraLookingAtCenterCoordinate:center fromEyeCoordinate:center eyeAltitude:1000];
    
    _mapView = [[FZMapView alloc] initWithInitialCamera:nil];
    _mapView.fzDelegate = self;
    self.mapView.showsUserLocation = YES;
    
    [self.view addSubview:_mapView];
    _mapView.translatesAutoresizingMaskIntoConstraints = NO;
    return _mapView;
}

- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView {
    NSLog(@"Statrting to locate user");
}

@end
