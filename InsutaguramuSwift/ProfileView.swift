//
//  ProfileView.swift
//  InsutaguramuSwift
//
//  Created by 小暮準才 on 2022/07/31.
//

import SwiftUI
import SDWebImageSwiftUI

struct ProfileView: View {
    @EnvironmentObject var vm : AuthViewModel
    
    var body: some View {
        VStack{
            WebImage(url: URL(string: vm.currentUser?.profileImageUrl ?? "no url"))
                .frame(width: 65, height: 65)
            
            Text(vm.currentUser?.email ?? "no email")
            Text(vm.currentUser?.name ?? "no name" )
            Text(vm.currentUser?.uid ?? "no uid" )
            Button {
                vm.logOut()
            } label: {
                Text("log out")
                    .foregroundColor(Color.white)
                    .padding()
            }
            .background(Capsule().fill(Color.red))
            .padding()

        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthViewModel())
    }
}
