//
//  ContentViewModel.swift
//  FaceKit
//
//  Created by hassan uriostegui on 1/3/23.
//

import Combine
import FaceKit
import UIKit

class ContentViewModel: ObservableObject {
    @Published var landmarks: Landmarks?
    @Published var pose: Pose?
    @Published var image: UIImage!
    init() {
        guard let image = UIImage(named: "facekit") else {
            fatalError()
        }
        self.image = image
    }
}

extension ContentViewModel {
    func loadDemoImage() {}

    func anazlyzePose() {
        landmarks = FaceKit.landmarks(from: image)
    }
}

extension ContentViewModel {
    func updatePoseEstimate() {}

    func update3dReconstruction() {}

    func updateUVMapping() {}
}
