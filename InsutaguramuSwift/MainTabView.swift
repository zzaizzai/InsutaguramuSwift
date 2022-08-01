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
            TabView(){
                PostsView()
//                    .environmentObject(AuthViewModel())
                    .tabItem {
                        Image(systemName: "house")
                    }
                    .tag("hello")
                
                UploadPost()
                    .tabItem {
                        Image(systemName: "pencil")
                    }
                    .tag("hello")
                
                Text("message")
                    .tabItem {
                        Image(systemName: "message")
                    }
                    .tag("hello")
                
                ProfileView()
//                    .environmentObject(AuthViewModel())
                    .tabItem {
                        Image(systemName: "person")
                    }
                    .tag("profile")
            }
        }


    }
}

//struct MainTabView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainTabView()
//    }
//}
