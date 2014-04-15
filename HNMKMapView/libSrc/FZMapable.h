//
//  FZMapable.h
//  Pods
//
//  Created by Michael Charkin on 4/15/14.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol FZMapable <MKAnnotation>

@property (nonatomic, strong, readonly) NSString *_id;

@end
