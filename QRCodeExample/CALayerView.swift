//
//  CALayerView.swift
//  QRCodeExample
//
//  Created by Yasuyuki Komatsubara on 2020/09/28.
//

import SwiftUI
import AVFoundation
import Combine
import ComposableArchitecture

struct State {
    var code: String?
}

enum Action: Equatable {
    case catchedCode(String)
}

let reducer = Reducer<State, Action, Void> { state, action, _ in
    switch action {
    case let .catchedCode(code):
    state.code = code
    return .none

    }
}
struct CALayerView: UIViewControllerRepresentable {
    let store: Store<State, Action>
    
    func makeCoordinator() -> Coordinator {
        Coordinator(code: nil)
    }
    
    var caLayer:CALayer

    func makeUIViewController(context: UIViewControllerRepresentableContext<CALayerView>) -> UIViewController {
        let viewController = UIViewController()

        viewController.view.layer.addSublayer(caLayer)
        caLayer.frame = viewController.view.layer.frame

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<CALayerView>) {
        caLayer.frame = uiViewController.view.layer.frame
    }
    
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        @Binding private var code: String?
        
        var previewLayer: AVCaptureVideoPreviewLayer!
        
        init(code: Binding<String?>) {
            _code = code

        }
        
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if metadataObjects.count > 0 {
                for metadata in metadataObjects as! [AVMetadataMachineReadableCodeObject] {
                    if metadata.type == .qr {
                        code = metadata.stringValue!
                    }
                }
            } else {
                code = nil
            }
        }
    }
}
