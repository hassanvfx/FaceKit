//
//  Header.h
//  
//
//  Created by hassan uriostegui on 1/4/23.
//

#ifndef FaceKitObj_h
#define FaceKitObj_h
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface FKPoint2D: NSObject
@property(atomic)NSNumber *x;
@property(atomic)NSNumber *y;
@end

@interface FKPoint3D: NSObject
@property(atomic)NSNumber *x;
@property(atomic)NSNumber *y;
@property(atomic)NSNumber *z;
@end

@interface FKLandmarks: NSObject
@property(atomic)NSArray<FKPoint2D*>*keypoints;
@end

@interface FKPose: NSObject
@property(atomic)FKPoint3D*position;
@property(atomic)FKPoint3D*rotation;
@end

@interface FKGeometry: NSObject
@property(atomic)NSArray<FKPoint3D*>*vertex;
@property(atomic)NSArray<FKPoint2D*>*indices;
@end

@interface FaceKitObjC: NSObject
+(FKLandmarks*)landmarksForImage:(UIImage*)image;
+(FKPose*)poseForLandmarks:(FKLandmarks*)landmarks;
+(FKGeometry*)geometryFromLandmarks:(FKLandmarks*)landmarks;
+(UIImage*)uvMapFromImages:(NSArray<UIImage*>*)images geo:(FKGeometry*)geo;
@end
NS_ASSUME_NONNULL_END

#endif /* Header_h */
