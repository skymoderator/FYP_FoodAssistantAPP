//
//  BoundingBoxView.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 16/11/2022.
//

import SwiftUI
import SwiftUIX

struct BoundingBoxView: View {
    
    @ObservedObject var vm: CameraViewModel
    
    let size: CGSize
    let offset: CGFloat
    let ratio: CGFloat
    let rescaledSize: CGSize
    
    init(
        vm: CameraViewModel,
        size: CGSize
    ) {
        self._vm = ObservedObject(wrappedValue: vm)
        self.size = size
        
        switch vm.captureSource {
        case .byImagePicker:
            self.rescaledSize = vm.pickerService.photo?.rescaledImage?.size ?? .zero
            self.offset = (416 - min(rescaledSize.width, rescaledSize.height))/2
            self.ratio = min(size.width, size.height)/min(rescaledSize.width, rescaledSize.height)
        case .byCamera:
            self.rescaledSize = vm.cameraService.photo?.rescaledImage?.size ?? .zero
            self.offset = (416 - min(rescaledSize.width, rescaledSize.height))/2
            self.ratio = min(size.width, size.height)/min(rescaledSize.width, rescaledSize.height)
        case nil:
            self.offset = .zero
            self.rescaledSize = .zero
            self.ratio = .zero
        }
    }
    
    var body: some View {
        ForEach(vm.ntDetection.boundingBoxes) { (bbox: BoundingBox) in
            let x: CGFloat = (bbox.rect.minX - bbox.rect.width/2 - self.offset) * ratio
            let y: CGFloat = (bbox.rect.minY - bbox.rect.height/2) * ratio
            Text("\(bbox.score)")
                .productFont(.bold, relativeTo: .caption)
                .frame("\(bbox.score)".productAttributeSize(.bold, relativeTo: .subheadline))
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .offset(x: x - 20, y: y - 20)
            Rectangle()
                .stroke(Color.red, lineWidth: 1.0)
                .frame(width: bbox.rect.width * ratio, height: bbox.rect.height * ratio)
                .offset(x: x, y: y)
        }
    }
}
