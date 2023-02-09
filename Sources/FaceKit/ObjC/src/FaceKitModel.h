//
//  FaceKitModel.h
//
//  Created by Hassan Uriostegui

#include <opencv2/opencv.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#import <ncnn/ncnn/net.h>

#include "mtcnn/mtcnn.h"
#include "prnet/prnet.h"
#include "prnet/face-data.h"
#include "prnet/mesh_core.h"
#include "../include/FaceKitObjC.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import <UIKit/UIKit.h>
#import <Endian.h>
#import <CoreML/CoreML.h>
#import <Vision/Vision.h>

#define KPT_COUNT 68

@interface FaceKitModel: NSObject {
    
    uint8_t *originData;
    
//    CIDetector * faceDetector;
//    CIDetector * textDetector;
//    VNDetectFaceLandmarksRequest *faceLandmarks;
//    
//    VNDetectFaceRectanglesRequest *faceRectangles;
//    VNSequenceRequestHandler *faceSequenceRequest;
//    
//    VNDetectTextRectanglesRequest *textRectangles;
//    VNSequenceRequestHandler *textSequenceRequest;
    
    MTCNN mtcnn;
    prnet *irModel;
    float *faceVector;
    uint8_t *planerData;
    ncnn::Net faceNet;
    cv::Mat resultMat;
    float *baseMatrix;
    double *inputData;
    float *posTemp;
    float *verticesTemp;
    float *new_image;
    uint8_t *face_mask;
    uint8_t *output_image;
    float *depth_buffer;
    bool isPoseEstimate;
    
    float *texture_color;
    
    FaceData face_data;
}

@property(weak, nonatomic) IBOutlet UIImageView *imageView;
+ (id) shared;
+(cv::Mat)cvMatFromUIImage:(UIImage *)image;
+(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat;
+(FKLandmarks*)landmarksForImage:(UIImage*)image;
+(FKPose*)poseForLandmarks:(FKLandmarks*)landmarks;
+(FKGeometry*)geometryFromLandmarks:(FKLandmarks*)landmarks;
+(UIImage*)uvMapFromImages:(NSArray<UIImage*>*)images geo:(FKGeometry*)geo;
@end
