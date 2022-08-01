//
//  MainTabView.swift
//  InsutaguramuSwift
//
//  Created by 小暮準才 on 2022/07/31.
//

import SwiftUI

struct MainTabView: View {
    
    @State private var titleName = "main"
    
    var body: some View {
        NavigationView{
            TabView(selection: $titleName){
                MainPostsView()
//                    .environmentObject(AuthViewModel())
                    .tabItem {
                        Image(systemName: "house")
                    }
                    .tag("hello")
                
                UploadPost()
                    .tabItem {
                        Image(systemName: "pencil")
                    }
                    .tag("upload")
                
                Text("message")
                    .tabItem {
                        Image(systemName: "message")
                    }
                    .tag("33")
                
                ProfileView()
//                    .environmentObject(AuthViewModel())
                    .tabItem {
                        Image(systemName: "person")
                    }
                    .tag("44")
            }
            .navigationTitle(self.titleName)
            .navigationBarTitleDisplayMode(.inline)
        }

    }
}

//struct MainTabView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainTabView()
//    }
//}
