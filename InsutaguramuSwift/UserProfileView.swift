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
    @Published var currentProfileUser : User?
    @Published var profileUserPosts = [Post]()
    @Published var profileUserLikedPosts = [Post]()
    
    init(userUid: String) {
        self.userUid = userUid
        fetchUserPorifle()
        fetchUserPosts(userUid: userUid)
        fetchMyLikedPost(postUid: userUid)
    }
    
    func fetchUserPorifle() {
        
        Firestore.firestore().collection("users").document(self.userUid).getDocument { snapshot, error in
            if let error = error {
                print(error)
                return
            }
            
            guard let documentId = snapshot?.documentID else { return }
            guard let data = snapshot?.data() else { return }
            
            self.currentProfileUser = User(documentId: documentId, data: data)
            
        }
        
    }
    
    func fetchUserPosts(userUid: String) {
        
        
        Firestore.firestore().collection("posts").whereField("authorUid", isEqualTo: userUid).order(by: "time").getDocuments { snapshots, error in
            if let error = error {
                print(error)
                return
            }
            
            snapshots?.documents.forEach({ doc in
                let documentId = doc.documentID
                let data = doc.data()
                
                self.profileUserPosts.insert(.init(documentId: documentId, data: data), at: 0)
            })
            
            
        }
    }
    
    func fetchUserLikedPosts(userUid: String) {
        
        
        Firestore.firestore().collection("likes").whereField("authorUid", isEqualTo: userUid).order(by: "time").getDocuments { snapshots, error in
            if let error = error {
                print(error)
                return
            }
            
            snapshots?.documents.forEach({ doc in
                let documentId = doc.documentID
                let data = doc.data()
                
                self.profileUserPosts.insert(.init(documentId: documentId, data: data), at: 0)
            })
        }
    }
    
    
    func fetchMyLikedPostsUid(userUid: String, completion: @escaping(String) -> Void) {
        
        
        Firestore.firestore().collection("likes").document(userUid).collection("likes-posts").order(by: "postTime", descending: false).getDocuments { snapshot, error in
            if let error = error {
                print(error)
                return
            }
            
            snapshot?.documents.forEach({ doc in
                let documentId = doc.documentID
                completion(documentId)
                
            })
        }
    }
    
    func fetchMyLikedPost(postUid: String) {
        
        fetchMyLikedPostsUid(userUid: postUid) { postUid in
            
            Firestore.firestore().collection("posts").document(postUid).getDocument { snapshot, error in
                if let error = error {
                    print(error)
                    return
                }
                
                guard let data = snapshot?.data() else { return }
                guard let documentId = snapshot?.documentID else { return }
                
                self.profileUserLikedPosts.insert(.init(documentId: documentId, data: data), at: 0)
                
            }
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
                            WebImage(url: URL(string: vm.currentProfileUser?.profileImageUrl ?? "no url"))
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
                            
                            Text(vm.profileUserPosts.count.description)
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
                        Text(vm.currentProfileUser?.email ?? "no email")
                        Text(vm.currentProfileUser?.name ?? "no name" )
                        //                        Text(vmAuth.currentUser?.uid ?? "no uid" )
                        Text(vm.currentProfileUser?.profileText ?? "no profil text")
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    filterBar
                    
                    profilePostsview
                    
                    
                }
                //                    .navigationBarTitleDisplayMode(.inline)
                .navigationTitle(vm.currentProfileUser?.name ?? "user name" )
                
                
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
                    //                    Text("myposts")
                    ForEach(vm.profileUserPosts){ myPost in
                        PostView(nonCheckedPost: myPost)
                        //                        Text("myposts")
                        
                    }
                }
            } else {
                VStack{
                    ForEach(vm.profileUserLikedPosts){ likedpost in
                        PostView(nonCheckedPost: likedpost)
                    }
                }
            }
        }
        
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            UserProfileView(userUid: "Akct8DqUtdZJYCc9yn2UojJqlNY2")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
