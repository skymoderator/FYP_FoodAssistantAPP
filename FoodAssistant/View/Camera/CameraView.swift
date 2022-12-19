//
//  CameraView.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 17/11/2022.
//

import SwiftUI

struct CameraView: View {
    
    @EnvironmentObject var mvm: MainViewModel
    let view = VideoPreviewView()
    
    var body: some View {
        GeometryReader { (proxy: GeometryProxy) in
            let size: CGSize = proxy.size
            ZStack {
                if let image: UIImage = mvm.cvm.displayedImage {
                    DisplayedImageView(vm: mvm.cvm, image: image)
                } else {
                    CameraPreview(session: mvm.cvm.cameraService.session)
                        .onTapGesture {
                            print(mvm.cvm.cameraService.isSessionRunning)
                        }
                }
                Color.black
                    .opacity(mvm.cvm.cameraService.willCapturePhoto ? 1 : 0)
            }
            .frame(width: size.width, height: size.height)
        }
        .fullScreen()
        .clipped()
        .edgesIgnoringSafeArea(.all)
        .sheet(
            isPresented: $mvm.cvm.pickerService.showImagePicker,
            onDismiss: mvm.cvm.captureGalleryImage
        ) {
            ImagePicker(image: $mvm.cvm.pickerService.image, camera: false)
        }
    }
}

fileprivate struct DisplayedImageView: View {
    
    @ObservedObject var vm: CameraViewModel
    let image: UIImage
    
    var body: some View {
        return Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: vm.isScaleToFill ? .fill : .fit)
            .overlay {
                GeometryReader {
                    BoundingBoxView(vm: vm, size: $0.size)
                }
            }
    }
}

struct CameraView_Previews: PreviewProvider {
    @StateObject static var mvm = MainViewModel()
    static var previews: some View {
        CameraView()
            .environmentObject(mvm)
    }
}
