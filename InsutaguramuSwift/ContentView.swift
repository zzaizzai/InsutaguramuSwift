//
//  ContentView.swift
//  InsutaguramuSwift
//
//  Created by 小暮準才 on 2022/07/31.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var vmAuth : AuthViewModel
    
    var body: some View {
        VStack{
            if vmAuth.userSession == nil {
                LoginView()
            } else {
                MainTabView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthViewModel())
    }
}
