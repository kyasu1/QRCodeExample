//
//  QRCodeExampleApp.swift
//  QRCodeExample
//
//  Created by Yasuyuki Komatsubara on 2020/09/28.
//

import SwiftUI
import ComposableArchitecture

@main
struct QRCodeExampleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView(
                store: Store(initialState: AppState(itemCode: .notAsked, scanner: ScanState(code: nil)), reducer: appReducer, environment: AppEnvironment(
                    avFoundationVM: AVFoundationVM()
                ))
            )
        }
    }
}
