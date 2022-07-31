//
//  InsutaguramuSwiftApp.swift
//  InsutaguramuSwift
//
//  Created by 小暮準才 on 2022/07/31.
//

import SwiftUI
import Firebase

@main
struct InsutaguramuSwiftApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
//            ContentView()
            LoginView()
                .environmentObject(AuthViewModel())
        }
    }
}
