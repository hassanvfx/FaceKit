//
//  FaceKitModel.m
//  VideoFace
//
//  Created by Hassan Uriostegui
//

#import "FaceKitModel.h"
#import <CoreGraphics/CGContext.h>
#include <set>

@interface FaceKitModel ()

@end


@implementation FaceKitModel
+ (id) shared {
    static dispatch_once_t pred = 0;
    static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

-(instancetype)init{
    self=[super init];
    if(self){
        [self setup];
    }
    return  self;
}

-(void)setup{
    
    /////////////mtcnn-ncnn
    char *path = (char *)[[[NSBundle mainBundle] resourcePath] UTF8String];
    mtcnn.init(path);
    mtcnn.SetMinFace(40);
    planerData = NULL;
   
    irModel = [[prnet alloc] init];
    inputData = (double *)malloc(sizeof(double)*256*256*3);
    
    posTemp = (float *)malloc(256*256*3*sizeof(float));
    verticesTemp = (float *)malloc(256*256*3*sizeof(float));
    new_image = (float *)malloc(640*480*3*sizeof(float));
    face_mask = (uint8_t *)malloc(640*480*sizeof(uint8_t));
    output_image = (uint8_t *)malloc(640*480*3*sizeof(uint8_t));
    
    memset(new_image, 0, 640*480*3*sizeof(float));
    memset(face_mask, 0, 640*480*sizeof(uint8_t));
    memset(output_image, 0, 640*480*3*sizeof(uint8_t));
    
    depth_buffer = (float *)malloc(640*480*sizeof(float));
    float *pos = (float *)malloc(256*256*3*sizeof(float));
    
    LoadFaceData([[[NSBundle mainBundle] resourcePath] UTF8String], &face_data);
    
    // Feed reconstructing image to PRNet
    vector<uint32_t> keypoints;
    cv::Mat imgMat = cv::imread([[[NSBundle mainBundle] pathForResource:@"ref" ofType:@"jpg"] UTF8String]);
    
    int faceCount = [self process:imgMat pos:pos keypoints:&keypoints];
    // pos ==> (uuuuu..., vvvvv..., zzzzz...)

    if(faceCount>0) {

        cv::Mat ref_pos1 = cv::Mat(256,256, CV_32F, pos);
        cv::Mat ref_pos2 = cv::Mat(256,256, CV_32F, pos + 256*256);
        
        cv::Mat posMat;
        vector<cv::Mat> posMats;
        posMats.push_back(ref_pos1);
        posMats.push_back(ref_pos2);
        cv::merge(posMats, posMat);
        
        imgMat.convertTo(imgMat, CV_32FC3, 1/256.0);
        
        // remap u,v coordinates(posMat) of imgMat to remapMat
        cv::Mat remapMat;
        cv::remap(imgMat, remapMat, posMat, cv::Mat(), cv::INTER_NEAREST);
        
        texture_color = (float *)malloc(face_data.face_indices.size()*sizeof(float)*3);
        int count = 0;
        vector<cv::Mat> xc2;
        split(remapMat, xc2);
        
        // Render to texture_color using rgb of remapMat at 43867 points.
        for (int i=0; i<face_data.face_indices.size(); i++) {
            int ind = face_data.face_indices[i];
            texture_color[count++] = *((float *)xc2[0].data+ ind);
            texture_color[count++] = *((float *)xc2[1].data+ ind);
            texture_color[count++] = *((float *)xc2[2].data+ ind);
        }
    }
   
    
}

+(FKLandmarks*)landmarksForImage:(UIImage*)image{
    cv::Mat imgMat=[FaceKitModel cvMatFromUIImage:image];
    float *posTemp = (float *)malloc(256*256*3*sizeof(float));
    vector<uint32_t> keypoints;

    int faceCount = [[FaceKitModel shared] process:imgMat pos: posTemp keypoints: &keypoints];

    FKLandmarks *landmarks = [FKLandmarks new];

    NSMutableArray* keypointsObjc = [NSMutableArray array];
    unsigned long keypointsCount = keypoints.size() / 2;
    for (int i = 0; i < keypointsCount; i++) {
        FKPoint2D* point = [FKPoint2D new];
        point.x = @(keypoints[i]);
        point.y = @( keypoints[i+keypointsCount]);
        [keypointsObjc addObject:point];
    }
    landmarks.keypoints = keypointsObjc;
//    landmarks->posTemp = posTemp;
    
    return landmarks;
}
+(FKPose*)poseForLandmarks:(FKLandmarks*)landmarks{
    return [FKPose new];
}
+(FKGeometry*)geometryFromLandmarks:(FKLandmarks*)landmarks{
    // Custom geometry with UV texture mapping
// https://gist.github.com/norman784/61025558fff27eb76162b7e4d1719a97
    return [FKGeometry new];
}
+(UIImage*)uvMapFromImages:(NSArray<UIImage*>*)images geo:(FKGeometry*)geo{
    //ERROR
}

#pragma  mark -helpers


+ (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    size_t numberOfComponents = CGColorSpaceGetNumberOfComponents(colorSpace);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;

    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    CGBitmapInfo bitmapInfo = kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault;

    // check whether the UIImage is greyscale already
    if (numberOfComponents == 1){
        cvMat = cv::Mat(rows, cols, CV_8UC1); // 8 bits per component, 1 channels
        bitmapInfo = kCGImageAlphaNone | kCGBitmapByteOrderDefault;
    }

    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,             // Pointer to backing data
                                                cols,                       // Width of bitmap
                                                rows,                       // Height of bitmap
                                                8,                          // Bits per component
                                                cvMat.step[0],              // Bytes per row
                                                colorSpace,                 // Colorspace
                                                bitmapInfo);              // Bitmap info flags

    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);

    return cvMat;
}


+(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat {
    
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

bool isInside(cv::Rect rect1, cv::Rect rect2) {
    return (rect1 == (rect1&rect2));
}

#pragma mark - drawing

void drawKeyPoint(const cv::Mat &img, vector<uint32_t> realPos) {// 68 Key Points.

    std::set<uint32_t> end_list = {16, 21, 26, 41, 47, 30, 35, 67};
    if(realPos.size()==0) {
        return;
    }

    for (int i = 0; i < KPT_COUNT; i++) {
        cv::circle(img, cv::Point(realPos[i*2], realPos[i*2+1]), 2, CV_RGB(255, 255, 0), cv::FILLED);
        auto search = end_list.find(i);
        if (search != end_list.end()) {
            continue;
        }
        cv::line(img, cv::Point(realPos[i*2], realPos[i*2+1]), cv::Point(realPos[(i+1)*2], realPos[(i+1)*2+1]), CV_RGB(255, 255, 0));
    }
}

void drawPose(const cv::Mat &img, cv::Mat point_2d) {   // Perspective Box.
    
    if(!point_2d.empty()) {
        
        point_2d.convertTo(point_2d, CV_32S);
        cv::polylines(img, point_2d, TRUE, CV_RGB(0, 255, 0), 2, cv::LINE_AA);
        
        cv::line(img, cv::Point(point_2d.at<uint32_t>(1,0), point_2d.at<uint32_t>(1,1)), cv::Point(point_2d.at<uint32_t>(6,0), point_2d.at<uint32_t>(6,1)), CV_RGB(0, 255, 0), 2, cv::LINE_AA);
        
        cv::line(img, cv::Point(point_2d.at<uint32_t>(2,0), point_2d.at<uint32_t>(2,1)), cv::Point(point_2d.at<uint32_t>(7,0), point_2d.at<uint32_t>(7,1)), CV_RGB(0, 255, 0), 2, cv::LINE_AA);
        
        cv::line(img, cv::Point(point_2d.at<uint32_t>(3,0), point_2d.at<uint32_t>(3,1)), cv::Point(point_2d.at<uint32_t>(8,0), point_2d.at<uint32_t>(8,1)), CV_RGB(0, 255, 0), 2, cv::LINE_AA);
    }
}

cv::Mat drawDetection(const cv::Mat &img, std::vector<Bbox> &box) {
    
    cv::Mat show = img.clone();
    int num_box = (int)box.size();
    std::vector<cv::Rect> bbox;
    bbox.resize(num_box);
    for (int i = 0; i < num_box; i++) {
        bbox[i] = cv::Rect(box[i].x1, box[i].y1, box[i].x2 - box[i].x1 + 1, box[i].y2 - box[i].y1 + 1);
        
        for (int j = 0; j < 5; j = j + 1) {
            cv::circle(show, cv::Point(box[i].ppoint[j], box[i].ppoint[j + 5]), 2, CV_RGB(0, 255, 0), cv::FILLED);
        }
    }
    int i=0;
    for (vector<cv::Rect>::iterator it = bbox.begin(); it != bbox.end(); it++) {
        rectangle(show, (*it), cv::Scalar(255, 127, 0), 2, 8, 0);
        cv::putText(show, box[i++].text, cv::Point((*it).x, (*it).y), cv::FONT_HERSHEY_COMPLEX, 0.8, CV_RGB(0, 255, 0),1);
    }
    return show;
}

#pragma mark - detection

-(MLMultiArray *)facePRNetCoreML:(cv::Mat) faceCrop {  //usr coreml.
    
    cv::resize(faceCrop, faceCrop, cv::Size(256, 256));
    vector<cv::Mat> xc;
    split(faceCrop, xc);
    
    int count = 0;
    for(int i=0; i<256*256; i++) {
        inputData[count++] = *(xc[2].data+i)/256.0;
    }
    for(int i=0; i<256*256; i++) {
        inputData[count++] = *(xc[1].data+i)/256.0;
    }
    for(int i=0; i<256*256; i++) {
        inputData[count++] = *(xc[0].data+i)/256.0;
    }
    
    MLMultiArray *arr = [[MLMultiArray alloc] initWithDataPointer:inputData shape:[NSArray arrayWithObjects:[NSNumber numberWithInt:3], [NSNumber numberWithInt:256], [NSNumber numberWithInt:256], nil] dataType:MLMultiArrayDataTypeDouble strides:[NSArray arrayWithObjects:[NSNumber numberWithInt:256*256], [NSNumber numberWithInt:256], [NSNumber numberWithInt:1], nil] deallocator:nil error:nil];
    
    prnetOutput *output = [irModel predictionFromPlaceholder__0:arr error:nil];
    MLMultiArray *multiArr = [output resfcn256__Conv2d_transpose_16__Sigmoid__0];
    
    return multiArr;
}

cv::Vec3f CalculateMean(const cv::Mat_<cv::Vec3f> &points) {
    
    cv::Mat_<cv::Vec3f> result;
    cv::reduce(points, result, 0, cv::REDUCE_AVG);
    return result(0, 0);
}

cv::Mat_<float> FindRigidTransform(const cv::Mat_<cv::Vec3f> &points1, const cv::Mat_<cv::Vec3f> points2) {
    
    /* Calculate centroids. */
    cv::Vec3f t1 = -CalculateMean(points1);
    cv::Vec3f t2 = -CalculateMean(points2);
    
    cv::Mat_<float> T1 = cv::Mat_<float>::eye(4, 4);
    T1(0, 3) = t1[0];
    T1(1, 3) = t1[1];
    T1(2, 3) = t1[2];
    
    cv::Mat_<float> T2 = cv::Mat_<float>::eye(4, 4);
    T2(0, 3) = -t2[0];
    T2(1, 3) = -t2[1];
    T2(2, 3) = -t2[2];
    
    /* Calculate covariance matrix for input points. Also calculate RMS deviation from centroid
     * which is used for scale calculation.
     */
    cv::Mat_<float> C(3, 3, 0.0);
    float p1Rms = 0, p2Rms = 0;
    for (int ptIdx = 0; ptIdx < points1.rows; ptIdx++) {
        cv::Vec3f p1 = points1(ptIdx, 0) + t1;
        cv::Vec3f p2 = points2(ptIdx, 0) + t2;
        p1Rms += p1.dot(p1);
        p2Rms += p2.dot(p2);
        for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 3; j++) {
                C(i, j) += p2[i] * p1[j];
            }
        }
    }
    
    cv::Mat_<float> u, s, vh;
    cv::SVD::compute(C, s, u, vh);
    
    cv::Mat_<float> R = u * vh;
    
    if (cv::determinant(R) < 0) {
        R -= u.col(2) * (vh.row(2) * 2.0);
    }
    
    float scale = sqrt(p2Rms / p1Rms);
    R *= scale;
    
    cv::Mat_<float> M = cv::Mat_<float>::eye(4, 4);
    R.copyTo(M.colRange(0, 3).rowRange(0, 3));
    
    cv::Mat_<float> result = T2 * M * T1;
    result /= result(3, 3);
    
    return result.rowRange(0, 3);
}

-(cv::Mat)P2sRt:(cv::Mat_<float>) P {
    
    cv::Mat_<float> R1;
    cv::normalize(P.row(0)(cv::Rect(0,0,3,1)), R1);
    
    cv::Mat_<float> R2;
    cv::normalize(P.row(1)(cv::Rect(0,0,3,1)), R2);
    
    cv::Mat_<float> R3 = R1.cross(R2);
    vector<cv::Mat_<float>> R123;
    
    R123.push_back(R1);
    R123.push_back(R2);
    R123.push_back(R3);
    
    cv::Mat R;
    cv::vconcat(R123, R);
    return R;
}

void matrix2angle(cv::Mat R, float &yaw, float &pitch, float &roll) {
    
    if(R.at<float>(2, 0)!=0 || R.at<float>(2, 0)!=-1) {
        yaw = asin(R.at<float>(2, 0));
        pitch = atan2(R.at<float>(2, 1)/cos(yaw), R.at<float>(2, 2)/cos(yaw));
        roll = atan2(R.at<float>(1, 0)/cos(yaw), R.at<float>(0, 0)/cos(yaw));
    }
    else {
        float z = 0;
        if(R.at<float>(2, 0)!=-1) {
            yaw = M_PI/2;
            pitch = z + atan2(R.at<float>(0, 1), R.at<float>(0, 2));
        }
        else {
            yaw = -M_PI/2;
            pitch = -z + atan2(-R.at<float>(0, 1), -R.at<float>(0, 2));
        }
    }
}

#pragma mark - 3d pose estimation

-(int) estimate_pose:(cv::Mat) targetMat :(cv::Mat &) point_2d :(vector<uint32_t> *) keypoints {
    // textureColor ==> (rgb, rgb, rgb, ...)
    
   
    int faceCount = [self process:targetMat pos: posTemp keypoints: keypoints];
    
    if(faceCount>0) {
        
        int nver = (int)face_data.face_indices.size();
        
        // verticesTemp ==> (xyz, xyz, xyz, ...)
        cv::Mat_<cv::Vec3f> targetPoints = cv::Mat_<cv::Vec3f>(nver, 1);
        cv::Mat_<cv::Vec3f> canonicalPoints = cv::Mat_<cv::Vec3f>(nver, 1);
        vector<std::array<float, 3>> canonical_vertices = face_data.canonical_vertices;
        
        for (int i=0; i<nver; i++) {
            int ind = face_data.face_indices[i];
            targetPoints(i,0) = cv::Vec3f(*(posTemp+ ind),
                                          *(posTemp+256*256 + ind),
                                          *(posTemp+256*256*2 + ind));
            canonicalPoints(i,0) = cv::Vec3f(canonical_vertices[i].data()[0], canonical_vertices[i].data()[1], canonical_vertices[i].data()[2]);
        }

        // Use canonical and target (x,y,z) to estimate transform, refer to SVD.
        cv::Mat_<float> P_Mat = FindRigidTransform(canonicalPoints, targetPoints);
        cv::Mat R_Mat = [self P2sRt:P_Mat];
        
        // Rotation Matrix convert to 3 Euler angles.
        float yaw, pitch, roll;
        matrix2angle(R_Mat, yaw, pitch, roll);
        yaw *= 180/M_PI;
        pitch *= 180/M_PI;
        roll *= 180/M_PI;
        
        cv::Mat xy_kpt_Mat = cv::Mat(KPT_COUNT, 2, CV_32F);
        for(int i=0; i<KPT_COUNT; i++) {
            int x = face_data.uv_kpt_indices[i];
            int y = face_data.uv_kpt_indices[i+KPT_COUNT];
            int ind = y*256+x;
            
            xy_kpt_Mat.at<float>(i, 0) = *(posTemp+ ind);
            xy_kpt_Mat.at<float>(i, 1) = *(posTemp+256*256 + ind);
        }
        
        // Calculate perspective box, 8 vertices.
        float rear_size = 90;
        float rear_depth = 0;
        float front_size = 105;
        float front_depth = 110;
        float p3ds[10*3] = {-rear_size, -rear_size, rear_depth,
                            -rear_size, rear_size, rear_depth,
                            rear_size, rear_size, rear_depth,
                            rear_size, -rear_size, rear_depth,
                            -rear_size, -rear_size, rear_depth,
                            -front_size, -front_size, front_depth,
                            -front_size, front_size, front_depth,
                            front_size, front_size, front_depth,
                            front_size, -front_size, front_depth,
                            -front_size, -front_size, front_depth };
        cv::Mat point_3d = cv::Mat(10, 3, CV_32F, p3ds);
        float ones[10*1] = {1,1,1,1,1, 1,1,1,1,1};
        cv::Mat onesMat = cv::Mat(10, 1, CV_32F, ones);
        vector<cv::Mat> mats;
        mats.push_back(point_3d);
        mats.push_back(onesMat);
        
        cv::Mat point_3d_demo;
        cv::hconcat(mats, point_3d_demo);
        cv::transpose(P_Mat, P_Mat);
        point_2d = point_3d_demo*P_Mat;
        point_2d = point_2d(cv::Rect(0,0,2,point_2d.rows));
        
        cv::Mat mean1;
        cv::reduce(point_2d(cv::Rect(0,0,2,4)), mean1, 0, cv::REDUCE_AVG);
        
        cv::Mat mean2;
        cv::reduce(xy_kpt_Mat(cv::Rect(0,0,2,27)), mean2, 0, cv::REDUCE_AVG);
        
        mean1 = cv::repeat(mean1, point_2d.rows, 1);
        mean2 = cv::repeat(mean2, point_2d.rows, 1);
        
        point_2d = point_2d - mean1 + mean2;
    }
    return faceCount;
}

#pragma mark - RENDER FACE SWAP

-(cv::Mat) renderTexture:(cv::Mat) targetMat :(float *) textureColor :(uint8_t *) outputImage {
    
    // textureColor ==> (rgb, rgb, rgb, ...)
    int w = targetMat.cols;
    int h = targetMat.rows;
    
    vector<uint32_t> keypoints;
    int faceCount = [self process:targetMat pos:posTemp keypoints: &keypoints];
    
    if(faceCount>0) {
        
        int count = 0;
        int nver = (int)face_data.face_indices.size();
        int ntri = (int)face_data.triangles.size()/3;
        
        // verticesTemp ==> (xyz, xyz, xyz, ...)
        for (int i=0; i<nver; i++) {
            int ind = face_data.face_indices[i];
            verticesTemp[count++] = float(*(posTemp+ ind));
            verticesTemp[count++] = float(*(posTemp+256*256   + ind));
            verticesTemp[count++] = float(*(posTemp+256*256*2 + ind));
        }
        
        int *triangles = (int *)face_data.triangles.data();

        for(int i=0; i<w*h; i++) {
            depth_buffer[i] = -999999.0;
        }
        
        memset(face_mask, 0, 640*480*sizeof(uint8_t));
        
        // new_image ==> (rgb, rgb, rgb, ...)
        _render_colors_core(new_image, face_mask, verticesTemp, triangles, textureColor, depth_buffer, ntri, h, w, 3);
        
        vector<cv::Mat> xc;
        split(targetMat, xc);
        
        cv::Mat maskMat = cv::Mat(targetMat.rows, targetMat.cols, CV_8U, face_mask);
        cv::Rect rect = cv::boundingRect(maskMat);
        
        count = 0;
        for(int i=0; i<w*h; i++) {
            outputImage[count++] = uint8_t( *(xc[2].data+i)*(255-face_mask[i]) + new_image[i*3+2]*face_mask[i] );
            outputImage[count++] = uint8_t( *(xc[1].data+i)*(255-face_mask[i]) + new_image[i*3+1]*face_mask[i] );
            outputImage[count++] = uint8_t( *(xc[0].data+i)*(255-face_mask[i]) + new_image[i*3]*face_mask[i] );
        }
        
        cv::Mat ooo = cv::Mat(targetMat.rows, targetMat.cols, CV_8UC3, outputImage);
        cv::Mat outMat;
        
        cv::seamlessClone(ooo, targetMat, maskMat, cv::Point(int(rect.x+rect.width/2), int(rect.y+rect.height/2)), outMat, cv::NORMAL_CLONE);
        
        return outMat;
    }
    return targetMat;
}

#pragma  mark - POSE AND KEYPOINTS DETECTION

-(int) process: (cv::Mat) imgMat pos:(float *) pos keypoints:(vector<uint32_t> *)keypoints { // Detect, PRNet
    
    // ---- MTCNN ----
    ncnn::Mat ncnn_img = ncnn::Mat::from_pixels(imgMat.data, ncnn::Mat::PIXEL_RGB, imgMat.cols, imgMat.rows);
    std::vector<Bbox> finalBbox;

    mtcnn.detect(ncnn_img, finalBbox);

    int num_box = (int)finalBbox.size();
    
    if(num_box>0) {
        
        // ---- The most probable face.
        float maxScore=0;
        int maxProbIndex=0;
        for(int i=0; i<finalBbox.size(); i++) {
            if(finalBbox[i].score>maxScore) {
                maxScore = finalBbox[i].score;
                maxProbIndex = i;
            }
        }
        
        int left = finalBbox[maxProbIndex].x1;
        int right = finalBbox[maxProbIndex].x2;
        int top = finalBbox[maxProbIndex].y1;
        int bottom = finalBbox[maxProbIndex].y2;
        
        float old_size = (right-left+bottom-top)/2.0;
        float centerX = right - (right-left)/2.0;
        float centerY = bottom - (bottom-top)/2 + old_size*0.14;
        int size = int(old_size*1.32);
        
        int x1 = centerX-size/2;
        int y1 = centerY-size/2;
        int x2 = centerX+size/2;
        int y2 = centerY+size/2;
        int width = x2 - x1;
        int height = y2 - y1;
        
        double scale = 256.0/width;
        double transX = -x1*scale;
        double transY = -y1*scale;
        int rectify_x1 = x1;
        int rectify_y1 = y1;
        
        // Expand face area to larger region, padding to 0 if out of bound.
        if(x2>imgMat.cols) {
            cv::copyMakeBorder(imgMat, imgMat, 0, 0, 0, x2-imgMat.cols, cv::BORDER_CONSTANT, cv::Scalar(0));
        }
        if(x1<0) {
            cv::copyMakeBorder(imgMat, imgMat, 0, 0, -x1, 0, cv::BORDER_CONSTANT, cv::Scalar(0));
            rectify_x1 = 0;
        }
        if(y2>imgMat.rows) {
            cv::copyMakeBorder(imgMat, imgMat, 0, y2-imgMat.rows, 0, 0, cv::BORDER_CONSTANT, cv::Scalar(0));
        }
        if(y1<0) {
            cv::copyMakeBorder(imgMat, imgMat, -y1, 0, 0, 0, cv::BORDER_CONSTANT, cv::Scalar(0));
            rectify_y1 = 0;
        }
        
        // ---- PRNet ----
        MLMultiArray *multiArr = [self facePRNetCoreML:imgMat(cv::Rect(rectify_x1, rectify_y1, width, height)).clone()];

        int plannerSize = [[multiArr strides][0] intValue];
        double *dataPointer = (double *)[multiArr dataPointer];
        
        for (int i=0; i<KPT_COUNT; i++) {   //68 Key Points.
            
            int ind_y = face_data.uv_kpt_indices[i+KPT_COUNT];
            int ind_x = face_data.uv_kpt_indices[i];
            double u_data = *(dataPointer + ind_y*256 + ind_x);
            double v_data = *(dataPointer + plannerSize + ind_y*256 + ind_x);
            
            keypoints->push_back(uint32_t(u_data*1.1*width + x1));
            keypoints->push_back(uint32_t(v_data*1.1*width + y1));
        }
        
        for(int i=0; i<plannerSize*3; i++) {
            dataPointer[i] *= 1.1*256;
        }
        
        // (posMat1, posMat2) means (u,v), posMat3 means depth (z).
        cv::Mat posMat1(1,256*256,CV_64F, dataPointer);
        cv::Mat posMat2(1,256*256,CV_64F, dataPointer + plannerSize);
        cv::Mat posMat3(1,256*256,CV_64F, dataPointer + plannerSize*2);

        // Only do 2D transform to origin size. z is reserved(only scale).
        // Since image is planner of 2D.
        double tformData[9] = {scale,0.0,transX, 0.0,scale,transY, 0.0,0.0,1.0};
        cv::Mat tform(3,3,CV_64F, tformData);
        cv::Mat z = posMat3/scale;
        posMat3.setTo(cv::Scalar(1));

        // posMats is 3* 65536 Matrix.
        cv::Mat posMats;
        posMats.push_back(posMat1);
        posMats.push_back(posMat2);
        posMats.push_back(posMat3);

        cv::Mat vertices;
        vertices = tform.inv()*posMats;
        z.row(0).copyTo(vertices.row(2));
        vertices.convertTo(vertices, CV_32F);

        // return pos(u,v,z) is refer to origin face size.
        memcpy(pos, vertices.data, 256*256*3*sizeof(float));
        
    }
    return num_box;
}


@end
