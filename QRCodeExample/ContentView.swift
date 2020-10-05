//
//  ContentView.swift
//  QRCodeExample
//
//  Created by Yasuyuki Komatsubara on 2020/09/28.
//

import SwiftUI
import ComposableArchitecture

struct AppState: Equatable {
    var itemCode: ItemCode<String> = .notAsked
    var scanner: ScanState
}

enum ItemCode<Data: Equatable>: Equatable {
    case notAsked
    case loading
    case success(Data)
    case failure
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
        state.itemCode = .loading
        return .none
    case .clickedCancelScan:
        state.itemCode = .notAsked
        return .none
    case let .scanAction(action: .catchedCode(code)):
        state.itemCode = .success(code!)
        return .none
    }
}

struct ContentView: View {
    let store: Store<AppState, AppAction>
    

    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            let button =                         Button(action: {
                viewStore.send(.clickedScanCodeButton)
            }) {
                Image(systemName: "camera.circle.fill")
                    .renderingMode(.original)
                    .resizable()
                    .frame(width: 80, height: 80, alignment: .center)
            }
            .padding(.bottom, 100.0)
            
            VStack {
                switch viewStore.itemCode {
                case .notAsked:
                    VStack() {
                        Text("READY TO READ")
                        button
                    }
                case .loading:
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
                case let .success(itemCode):
                    VStack() {
                        Text("Code is ")
                        Text("\(itemCode)")
                        button
                    }
                case .failure:
                    VStack() {
                        Text("Error !")
                        Text("Something went wrong")
                        button
                    }
                }
            }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView(
                store: Store(initialState: AppState(scanner: ScanState()), reducer: appReducer, environment: AppEnvironment(
                    avFoundationVM: AVFoundationVM()
                ))
            )
        }
    }
}
