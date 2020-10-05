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

struct ScanState: Equatable {
    var code: String? = nil
}

enum ScanAction: Equatable {
    case catchedCode(String?)
}

let reducer = Reducer<ScanState, ScanAction, Void> { state, action, _ in
    switch action {
    case let .catchedCode(code):
        state.code = code
        return .none
        
    }
}
struct CALayerView: UIViewControllerRepresentable {
    let store: Store<ScanState, ScanAction>
    let viewStore: ViewStore<ScanState, ScanAction>
    
    init(store: Store<ScanState, ScanAction>) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self,
                    code: viewStore.binding(get: {$0.code}, send: ScanAction.catchedCode))
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<CALayerView>) -> UIViewController {
        let viewController = AVFoundationViewController(delegate: context.coordinator)
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<CALayerView>) {
    }
    
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: CALayerView
        let code: Binding<String?>
        
        init(parent: CALayerView, code: Binding<String?>) {
            self.parent = parent
            self.code = code
        }
        
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if metadataObjects.count > 0 {
                for metadata in metadataObjects as! [AVMetadataMachineReadableCodeObject] {
                    if metadata.type == .qr {
                        self.code.wrappedValue = .some(metadata.stringValue!)
                    } else if metadata.type == .ean13 {
                        self.code.wrappedValue = .some(metadata.stringValue!)
                    }
                }
            } else {
                self.code.wrappedValue = .none
            }
        }
    }
    
    class AVFoundationViewController: UIViewController {
        var previewLayer:AVCaptureVideoPreviewLayer!
        private var captureSession = AVCaptureSession()
        private var captureDevice:AVCaptureDevice!
        private var delegate: Coordinator
        
        init(delegate: Coordinator) {
            self.delegate = delegate
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) is not supported")
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            if let availableDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                captureDevice = availableDevice
            } else {
                fatalError("Missing expected back camera device.")
            }
            
            do {
                let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
                
                captureSession.addInput(captureDeviceInput)
            } catch {
                print(error.localizedDescription)
            }
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            self.previewLayer = previewLayer
            
            let metadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self.delegate, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr, .ean13]
            
            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String:kCVPixelFormatType_32BGRA]
            
            if captureSession.canAddOutput(dataOutput) {
                captureSession.addOutput(dataOutput)
            }
            
            captureSession.commitConfiguration()
        }
        
        override public func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            self.previewLayer.frame = self.view.layer.bounds
            self.view.layer.addSublayer(self.previewLayer)
        }
        override public func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            if captureSession.isRunning { return }
            captureSession.startRunning()
        }
        
        override public func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            if !captureSession.isRunning { return }
            captureSession.stopRunning()
        }
    }
}
