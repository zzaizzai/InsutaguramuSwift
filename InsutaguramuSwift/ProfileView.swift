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
    @State var showOptions = false
    
    var body: some View {
        NavigationView {
            VStack {
//                HStack{
//                    Text("??")
//                }
                ScrollView {
                    VStack{
                        
                        HStack{
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
                            
                            Spacer()
                            
                            VStack{
                                
                                Text("1")
                                Text("posts")
                            }
                            
                            VStack{
                                
                                Text("1")
                                Text("follower")
                            }
                            
                            VStack{
                                
                                Text("1")
                                Text("following")
                            }
                        }
                        .padding(.horizontal)
                        
                        LazyVStack(alignment: .leading ) {
                            Text(vmAuth.currentUser?.email ?? "no email")
                            Text(vmAuth.currentUser?.name ?? "no name" )
    //                        Text(vmAuth.currentUser?.uid ?? "no uid" )
                            Text(vmAuth.currentUser?.profileText ?? "no profil text")
                        }
                        .padding(.horizontal)
                        
                        Divider()
                        
                        filterBar
                        
                        profilePostsview
                        
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle("profile")
                    .navigationBarItems(trailing:
                                            VStack{
                        Button {
                            self.showOptions.toggle()
                        } label: {
                            Image(systemName: "equal")
                                .foregroundColor(Color.black)
                        }
                        
                    }
                    )
                }
                .actionSheet(isPresented: $showOptions) {
                    .init(title: Text("title"),
                          buttons: [
                            .default(Text("setting"), action: {
                                print("setting")
                            }),
                            .destructive(Text("sign out"), action: {
                        vmAuth.logOut()
                    }), .cancel()
                                   ])
                }
            }
        }
    }
    
    let filters = ["posts", "liked"]
    @State var currentFilter : String = "posts"
    
    private var filterBar: some View {
        
        
        HStack{
            ForEach(filters, id: \.self) { filter in
                VStack{
                    Text(filter)
                    
                    if currentFilter == filter {
                        
                        Capsule()
                            .foregroundColor(Color.gray)
                    } else {
                        Capsule()
                            .foregroundColor(Color.clear)
                    }
                }
                .onTapGesture {
                    self.currentFilter = filter
                }
                
            }

        }
    }
    
    private var profilePostsview: some View {
        
        
        VStack{
            if self.currentFilter == "posts" {
                VStack{
                    ForEach(0..<5){ post in
                        Text("posts")
                    }
                }
            } else {
                VStack{
                    ForEach(0..<5){ post in
                        Text("liked")
                    }
                }
            }
        }
        
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthViewModel())
    }
}
