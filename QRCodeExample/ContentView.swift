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
    var isScanning: Bool
}

enum AppAction: Equatable {
    case clickedScanCodeButton
    case clickedCancelScan
    case scannedCode
}

struct AppEnvironment {
    var avFoundationVM: AVFoundationVM
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
    switch action {
    case .clickedScanCodeButton:
        state.isScanning = true
        return environment.avFoundationVM.takePhoto()
    case .clickedCancelScan:
        state.isScanning = false
        return .none
    case .scannedCode:
        state.itemCode = nil
        return .none
    }
}

struct ContentView: View {
    @Environment(\.avFoundationVM) var avFoundationVM
    let store: Store<AppState, AppAction>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                if viewStore.isScanning == false {
                    VStack() {
                        Text("QR Code is ")
                        Text("\(viewStore.itemCode!)")
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
                        CALayerView(caLayer: avFoundationVM.previewLayer)
                        
                        Button(action: {
                            viewStore.send(.clickedScanCodeButton)
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .renderingMode(.original)
                                .resizable()
                                .frame(width: 80, height: 80, alignment: .center)
                        }
                        .padding(.bottom, 100.0)
                        
                    }.onAppear {
                        self.avFoundationVM.startSession()
                    }.onDisappear {
                        self.avFoundationVM.endSession()
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
                store: Store(initialState: AppState(), reducer: appReducer, environment: AppEnvironment(
                    avFoundationVM: AVFoundationVM()
                ))
            )
        }
    }
}
