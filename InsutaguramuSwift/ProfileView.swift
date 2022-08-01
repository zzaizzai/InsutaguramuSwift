//
//  ProfileView.swift
//  InsutaguramuSwift
//
//  Created by 小暮準才 on 2022/07/31.
//

import SwiftUI
import SDWebImageSwiftUI

struct ProfileView: View {
    @EnvironmentObject var vmAuth : AuthViewModel
    
    var body: some View {
//        ScrollView{
            VStack{
                
                ZStack{
                    WebImage(url: URL(string: vmAuth.currentUser?.profileImageUrl ?? "no url"))
                        .resizable()
                        .frame(width: 120, height: 120)
                        .scaledToFill()
                        .cornerRadius(100)
                        .zIndex(1)
                    
                    Image(systemName: "person")
                        .font(.system(size: 110))
                        .background(Color.gray)
//                        .frame(width: 120, height: 120)
//                        .scaledToFill()
                        .cornerRadius(100)
                        
                }
                
                Text(vmAuth.currentUser?.email ?? "no email")
                Text(vmAuth.currentUser?.name ?? "no name" )
                Text(vmAuth.currentUser?.uid ?? "no uid" )
                Button {
                    vmAuth.logOut()
                } label: {
                    Text("log out")
                        .foregroundColor(Color.white)
                        .padding()
                }
                .background(Capsule().fill(Color.red))
                .padding()
                
                Text("my posts")

            }
//        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthViewModel())
    }
}
