//
//  ContentView.swift
//  QRCodeExample
//
//  Created by Yasuyuki Komatsubara on 2020/09/28.
//

import SwiftUI
import ComposableArchitecture

struct AppState: Equatable {
    var itemCode: String?
    var isScanning: Bool = false
    var scanner: ScanState
}

enum AppAction: Equatable {
    case clickedScanCodeButton
    case clickedCancelScan
    case scanAction(action: ScanAction)
}

struct AppEnvironment {
    var avFoundationVM: AVFoundationVM
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
    switch action {
    case .clickedScanCodeButton:
        state.isScanning = true
        return .none
    case .clickedCancelScan:
        state.isScanning = false
        return .none
    case let .scanAction(action: .catchedCode(code)):
        state.itemCode = code
        state.isScanning = false
        return .none
    }
}

struct ContentView: View {
    let store: Store<AppState, AppAction>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                if viewStore.isScanning == false {
                    if let itemCode = viewStore.itemCode {
                        VStack() {
                            Text("QR Code is ")
                            Text("\(itemCode)")
                        }
                    } else {
                        VStack() {
                            Text("NO QR CODE")
                        }
                    }
                    
                    Button(action: {
                        viewStore.send(.clickedScanCodeButton)
                    }) {
                        Image(systemName: "camera.circle.fill")
                            .renderingMode(.original)
                            .resizable()
                            .frame(width: 80, height: 80, alignment: .center)
                    }
                    .padding(.bottom, 100.0)
                } else {
                    Spacer()
                    
                    ZStack(alignment: .bottom) {
                        CALayerView(store: self.store.scope(state: {$0.scanner }, action: AppAction.scanAction))
                        
                        Button(action: {
                            viewStore.send(.clickedCancelScan)
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .renderingMode(.original)
                                .resizable()
                                .frame(width: 80, height: 80, alignment: .center)
                        }
                        .padding(.bottom, 100.0)
                    }
                    
                    Spacer()
                }
            }
            
        }
        
        //            if avFoundationVM.image == nil {
        //                Spacer()
        //
        //                ZStack(alignment: .bottom) {
        //                    CALayerView(caLayer: avFoundationVM.previewLayer)
        //
        //                    if let rect = avFoundationVM.rect {
        //                        Path.init(rect)
        //                            .stroke(Color.yellow, lineWidth: 4)
        //                    }
        //
        //                    Button(action: {
        //                        self.avFoundationVM.takePhoto()
        //                    }) {
        //                        Image(systemName: "camera.circle.fill")
        //                        .renderingMode(.original)
        //                        .resizable()
        //                        .frame(width: 80, height: 80, alignment: .center)
        //                    }
        //                    .padding(.bottom, 100.0)
        //                }.onAppear {
        //                    self.avFoundationVM.startSession()
        //                }.onDisappear {
        //                    self.avFoundationVM.endSession()
        //                }
        //
        //                Spacer()
        //            } else {
        //                ZStack(alignment: .topLeading) {
        //                    VStack {
        //                        Spacer()
        //
        //                        Image(uiImage: avFoundationVM.image!)
        //                        .resizable()
        //                        .scaledToFill()
        //                        .aspectRatio(contentMode: .fit)
        //
        //                        Spacer()
        //                    }
        //                    Button(action: {
        //                        self.avFoundationVM.image = nil
        //                    }) {
        //                            Image(systemName: "xmark.circle.fill")
        //                            .renderingMode(.original)
        //                            .resizable()
        //                            .frame(width: 30, height: 30, alignment: .center)
        //                            .foregroundColor(.white)
        //                            .background(Color.gray)
        //                    }
        //                    .frame(width: 80, height: 80, alignment: .center)
        //                }
        //            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView(
                store: Store(initialState: AppState(scanner: ScanState(code: nil)), reducer: appReducer, environment: AppEnvironment(
                    avFoundationVM: AVFoundationVM()
                ))
            )
        }
    }
}
