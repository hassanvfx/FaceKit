//
//  File.swift
//
//
//  Created by hassan uriostegui on 1/4/23.
//

import FaceKitObjC
import Foundation

public struct Point2d: Codable, Hashable {
    public var label: String?
    public var x: Float = 0
    public var y: Float = 0
    public init() {}
    public init(x: Float, y: Float) {
        self.x = x
        self.y = y
    }

    public init(from point: FKPoint2D) {
        x = Float(truncating: point.x)
        y = Float(truncating: point.y)
    }

    public func toObjc() -> FKPoint2D {
        let objcPoint = FKPoint2D()
        objcPoint.x = x as NSNumber
        objcPoint.y = y as NSNumber
        return objcPoint
    }
}

public struct Point3d: Codable, Hashable {
    public var label: String?
    public var x: Float = 0
    public var y: Float = 0
    public var z: Float = 0
    public init() {}
    public init(x: Float, y: Float, z: Float) {
        self.x = x
        self.y = y
        self.z = z
    }

    public init(from point: FKPoint3D) {
        x = Float(truncating: point.x)
        y = Float(truncating: point.y)
        z = Float(truncating: point.z)
    }

    public func toObjc() -> FKPoint3D {
        let objcPoint = FKPoint3D()
        objcPoint.x = x as NSNumber
        objcPoint.y = y as NSNumber
        objcPoint.z = z as NSNumber
        return objcPoint
    }
}

public struct Landmarks: Codable, Hashable {
    public var keypoints = [Point2d]()
    public init() {}
    public init(keypoints: [Point2d]) {
        self.keypoints = keypoints
    }

    public init(from landmarks: FKLandmarks) {
        keypoints = landmarks.keypoints.map { Point2d(from: $0) }
    }

    public func toObjc() -> FKLandmarks {
        let objcLandmarks = FKLandmarks()
        objcLandmarks.keypoints = keypoints.map { $0.toObjc() }
        return objcLandmarks
    }
}

public struct Pose: Codable, Hashable {
    public var position = Point3d()
    public var rotation = Point3d()
    public init(position: Point3d, rotation: Point3d) {
        self.position = position
        self.rotation = rotation
    }

    public init(from pose: FKPose) {
        position = Point3d(from: pose.position)
        rotation = Point3d(from: pose.rotation)
    }

    public func toObjc() -> FKPose {
        let objcPose = FKPose()
        objcPose.position = position.toObjc()
        objcPose.rotation = rotation.toObjc()
        return objcPose
    }
}

public struct Geometry: Codable, Hashable {
    public var vertex = [Point3d]()
    public var indices = [Point2d]()
    public init(vertex: [Point3d], indices: [Point2d]) {
        self.vertex = vertex
        self.indices = indices
    }

    public init(from geometry: FKGeometry) {
        vertex = geometry.vertex.map { Point3d(from: $0) }
        indices = geometry.indices.map { Point2d(from: $0) }
    }

    public func toObjc() -> FKGeometry {
        let objcGeo = FKGeometry()
        objcGeo.vertex = vertex.map { $0.toObjc() }
        objcGeo.indices = indices.map { $0.toObjc() }
        return objcGeo
    }
}
