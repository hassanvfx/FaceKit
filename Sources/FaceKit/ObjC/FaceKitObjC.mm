//Keep the openCV2 headers here to prvent linking issues
#include <opencv2/opencv.hpp>
#include <opencv2/core/core.hpp>
#import "include/FaceKitObjC.h"
#import "src/FaceKitModel.h"


@interface FaceKitObjC ()
@end

@implementation FaceKitObjC

+(FKLandmarks*)landmarksForImage:(UIImage*)image{
  return [FaceKitModel landmarksForImage:image];
}
+(FKPose*)poseForLandmarks:(FKLandmarks*)landmarks{
    return [FaceKitModel poseForLandmarks:landmarks];
}
+(FKGeometry*)geometryFromLandmarks:(FKLandmarks*)landmarks{
    return [FaceKitModel geometryFromLandmarks:landmarks];
}
+(UIImage*)uvMapFromImages:(NSArray<UIImage*>*)images geo:(FKGeometry*)geo{
    return [FaceKitModel uvMapFromImages:images geo:geo];
}

@end

#pragma mark -helpers

@interface FKPoint2D()
@end
@implementation FKPoint2D
@end

@interface FKPoint3D()
@end
@implementation FKPoint3D
@end

@interface FKLandmarks()
@end
@implementation FKLandmarks
@end

@interface FKPose()
@end
@implementation FKPose
@end

@interface FKGeometry()
@end
@implementation FKGeometry
@end

