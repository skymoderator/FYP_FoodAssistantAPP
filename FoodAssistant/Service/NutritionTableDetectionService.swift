//
//  NutritionTableDetectionService.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 4/12/2022.
//

import Foundation
import Vision
import UIKit

class NutritionTableDetectionService: ObservableObject {
    
    @Published var boundingBoxes: [BoundingBox] = []
    @Published var model: VNCoreMLModel?
    
    init() {
        Task(priority: .userInitiated) { [weak self] in
            print("Initializing YOLOv4")
            let model: VNCoreMLModel? = try? VNCoreMLModel(for: YOLOv4(configuration: .init()).model)
            await MainActor.run { [weak self] in
                self?.model = model
                print("Finished initializing YOLOv4")
            }
        }
    }
    
    func detectNuritionTable(image: UIImage) {
        guard let model else { return }
        let request = VNCoreMLRequest(model: model, completionHandler: visionRequestDidComplete)
        request.imageCropAndScaleOption = .scaleFill
        Task {
            var orientation: CGImagePropertyOrientation = .up
            if image.imageOrientation == .right {
                orientation = .right
            } else if image.imageOrientation == .left {
                orientation = .left
            }
            let handler = VNImageRequestHandler(cgImage: image.cgImage!, orientation: orientation)//options: [:]
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
        }
    }
    
    func visionRequestDidComplete(request: VNRequest, error: Error?) {
        Task { [weak self] in
            guard let self = self else { return }
            await MainActor.run { [weak self] in
                guard let self = self else { return }
                self.boundingBoxes.removeAll()
                if let observations = request.results as? [VNCoreMLFeatureValueObservation],
                   let bbox = observations.first?.featureValue.multiArrayValue {
                    let bboxShapedArray = MLShapedArray<Float>(bbox)
                    let predictions: [BoundingBox] = bboxShapedArray
                        .filter { (output: MLShapedArraySlice<Float>) in
                            output.scalars[4] > 0.5
                        }
                        .map {
                            (output: MLShapedArraySlice<Float>) -> BoundingBox in
                            let x = output.scalars
                            return BoundingBox(
                                classIndex: Int(x[5]),
                                score: x[4],
                                rect: CGRect(
                                    x: Int(x[0]),
                                    y: Int(x[1]),
                                    width: Int(x[2]),
                                    height: Int(x[3])
                                )
                            )
                        }
                    
                    let nms = NMS(bboxes: predictions, iouThreshold: 0.5, maxBoxes: 100)
                    let predictionsOut: [BoundingBox] = nms().map { predictions[$0] }
                    self.boundingBoxes = predictionsOut
                }
            }
        }
    }
    
}
