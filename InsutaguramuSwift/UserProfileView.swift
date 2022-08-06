//
//  UserProfileView.swift
//  InsutaguramuSwift
//
//  Created by 小暮準才 on 2022/08/06.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

class UserProfileViewModel: ObservableObject {
    
    let userUid : String
    @Published var currentProfile : User?
    
    init(userUid: String) {
        self.userUid = userUid
        fetchUserPorifle()
    }
    
    func fetchUserPorifle() {
        
        Firestore.firestore().collection("users").document(self.userUid).getDocument { snapshot, error in
            if let error = error {
                print(error)
                return
            }
            
            guard let documentId = snapshot?.documentID else { return }
            guard let data = snapshot?.data() else { return }
            
            self.currentProfile = User(documentId: documentId, data: data)
            
        }
        
    }
    
}

struct UserProfileView: View {
    let userUid: String
    @ObservedObject var vm : UserProfileViewModel
    
    @State var showOptions = false
    
    init(userUid: String){
        self.userUid = userUid
        self.vm = UserProfileViewModel(userUid: userUid)
        
        
    }
    
    var body: some View {
            VStack {
                ScrollView {
                    VStack{
                        
                        HStack{
                            ZStack{
                                WebImage(url: URL(string: vm.currentProfile?.profileImageUrl ?? "no url"))
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
                                
//                                Text(vm.myPosts.count.description)
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
//                            Text(vmAuth.currentUser?.email ?? "no email")
//                            Text(vmAuth.currentUser?.name ?? "no name" )
//                            //                        Text(vmAuth.currentUser?.uid ?? "no uid" )
//                            Text(vmAuth.currentUser?.profileText ?? "no profil text")
                        }
                        .padding(.horizontal)
                        
                        Divider()
                        
                        
                    }
//                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle(vm.currentProfile?.name ?? "user name" )
                    
                
            }
        }
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            UserProfileView(userUid: "Akct8DqUtdZJYCc9yn2UojJqlNY2")
        }
    }
}
