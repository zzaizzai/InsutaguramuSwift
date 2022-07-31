//
//  LoginView.swift
//  InsutaguramuSwift
//
//  Created by 小暮準才 on 2022/07/31.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var vm : AuthViewModel
    
    @State private var name = ""
    @State private var email = "test@test.com"
    @State private var password = "password"
    @State private var errorMessage = ""
    @State private var successMessage = ""
    
    var body: some View {
        ScrollView{
            VStack{
                Group {
                    //                        TextField("name", text: $name)
                    TextField("email", text: $email)
                    TextField("password", text: $password)
                }
                .padding()
                .background(Capsule().fill(Color.gray))
                .autocapitalization(.none)
                .padding()
                
                
                Button {
                    vm.login(email: self.email, password: self.password)
                } label: {
                    Spacer()
                    Text("login")
                        .foregroundColor(Color.white)
                        .padding()
                    Spacer()
                }
                .background(Capsule().fill(Color.blue))
                .padding()
                
                Button {
                    vm.register(email: self.email, password: self.password, name: "james")
                } label: {
                    Spacer()
                    Text("register")
                        .foregroundColor(Color.white)
                        .padding()
                    Spacer()
                }
                .background(Capsule().fill(Color.green))
                .padding()
                
                Button {
                    vm.logOut()
                } label: {
                    Spacer()
                    Text("log out")
                        .foregroundColor(Color.white)
                        .padding()
                    Spacer()
                }
                .background(Capsule().fill(Color.red))
                .padding()
                
                Button {
                    print("hello")
                } label: {
                    Text("go to register")
                }
                
                Text(vm.errorMessage)
                
                if vm.userSession == nil {
                    Text("no user session")
                    
                } else {
                    Text("good we have user session")
                }
                
                Text(vm.currentUser?.uid ?? "no uid")
                
            }
            
        }
        
        
        
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthViewModel())
    }
}
