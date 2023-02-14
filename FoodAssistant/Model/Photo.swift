//
//  Photo.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 9/11/2022.
//

import Foundation
import UIKit

//  MARK: Class Camera Service, handles setup of AVFoundation needed for a basic camera app.
struct Photo: Identifiable, Equatable {
    
    static let targetSize: CGSize = .init(width: 416, height: 416)
    // rescaledImage is image whose size is less than 416x416
    // and it is guaranteed to one side is 416
    // e.g. 416x312, 312x416
    static let rescaler = ImageRescaler(targetSize: targetSize)
    
    var id: String
    var image: UIImage?
    var resizedImage: UIImage?
    var rescaledImage: UIImage?
    
    init(
        id: String = UUID().uuidString,
        originalData: Data
    ) {
//        self.originalData = originalData
        self.init(image: UIImage(data: originalData))
    }
    
    init(
        id: String = UUID().uuidString,
        image: UIImage?
    ) {
        self.id = id
        self.image = image
        self.rescaledImage = Photo.rescaler(originalImage: self.image!)
        // resizedImage is an image whose size is strictly 416x416
        // and its background is black (can be changed)
        self.resizedImage = rescaledImage?.drawOnCanvas(withCanvasSize: Photo.targetSize, andCanvasColor: UIColor.black, atPosition: .middle)
    }
    
//    var compressedData: Data? {
//        let resizer = ImageResizer(targetSize: .init(width: 416, height: 416))
//        return resizer(data: originalData)?.jpegData(compressionQuality: 0.5)
//    }

    
//    var originalImage: UIImage? {
//        UIImage(data: originalData)
//    }

}
