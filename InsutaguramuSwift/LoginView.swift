//
//  LoginView.swift
//  InsutaguramuSwift
//
//  Created by 小暮準才 on 2022/07/31.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var vmAuth : AuthViewModel
    
    @State private var name = ""
    @State private var email = "test@test.com"
    @State private var password = "password"
    @State private var errorMessage = ""
    @State private var successMessage = ""
    @State private var showRegisterMode = false
    @State private var showImagePicker = false
    @State private var profileImage : UIImage?
    
    var body: some View {
        ScrollView{
            
            if self.showRegisterMode == false {
                
                loginPage
                
            } else {
                
                register
                
            }
        }
    }
    
    
    private var loginPage: some View {
        VStack{
            Group {
                //                        TextField("name", text: $name)
                TextField("email", text: $email)
                TextField("password", text: $password)
            }
            .padding()
            .background(Capsule().fill(Color.init(white: 0.8)))
            .autocapitalization(.none)
            .padding()
            
            
            Button {
                vmAuth.login(email: self.email, password: self.password)
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
                vmAuth.logOut()
            } label: {
                Spacer()
                Text("log out")
                    .foregroundColor(Color.white)
                    .padding()
                Spacer()
            }
            .background(Capsule().fill(Color.red))
            .padding()
            
            
            Text(vmAuth.errorMessage)
            
            Text("\(vmAuth.currentUser?.uid ?? "no uid")")
            
            
            Button {
                print("hello")
                self.showRegisterMode.toggle()
            } label: {
                Text("go to register")
            }
            
        }
    }
    
    private var register : some View {
        VStack{
            
            Group {
                TextField("name", text: $name)
                TextField("email", text: $email)
                TextField("password", text: $password)
            }
            .padding()
            .background(Capsule().fill(Color.init(white: 0.8)))
            .autocapitalization(.none)
            .padding()
            
            Button {
                self.showImagePicker.toggle()
            } label: {
                if let profileImage = self.profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .frame(width: 120, height: 120)
                        .scaledToFill()
                        .cornerRadius(100)
                    
                } else {
                    Image(systemName: "photo")
                        .font(.system(size: 60))
                        .foregroundColor(Color.black)
                        .padding()
                }
            }
            
            
            Button {
                registerButton()
            } label: {
                Spacer()
                Text("register")
                    .foregroundColor(Color.white)
                    .padding()
                Spacer()
            }
            .background(Capsule().fill(Color.green))
            .padding()
            
            ZStack{
                Text(vmAuth.errorMessage)
                Text(self.errorMessage)
            }
            
            Button {
                print("hello")
                self.showRegisterMode.toggle()
            } label: {
                Text("go to login page")
            }
            
        }
        .fullScreenCover(isPresented: $showImagePicker) {
            ImagePicker(image: $profileImage)
        }
    }
    
    func registerButton() {
        guard let newProfileImage = self.profileImage else {
            self.errorMessage = "no profile image"
            return }
        
        self.errorMessage = ""
        vmAuth.register(email: self.email, password: self.password, name: self.name, profileImage: newProfileImage){ didRegist in
            if didRegist == true {
                
                sleep(1)
                
                self.showRegisterMode = false
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
