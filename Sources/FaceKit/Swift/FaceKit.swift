//
//  File.swift
//
//
//  Created by hassan uriostegui on 1/4/23.
//

import FaceKitObjC
import Foundation

public enum FaceKit {
    public static func landmarks(from image: UIImage) -> Landmarks {
        Landmarks(from: FaceKitObjC.landmarks(for: image))
    }

    public static func pose(from _: Landmarks) -> Pose {
        let objcLandmark = FKLandmarks()
//        objcLandmark.points = landmarks.points.map{ point in
//            let objcPoint = FKPoint2D()
//            objcPoint.x = point.x as NSNumber
//            objcPoint.y = point.y as NSNumber
//            return objcPoint
//        }
        return Pose(from: FaceKitObjC.pose(for: objcLandmark))
    }
}
