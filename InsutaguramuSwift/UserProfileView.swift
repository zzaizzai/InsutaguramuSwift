//
//  UserProfileView.swift
//  InsutaguramuSwift
//
//  Created by 小暮準才 on 2022/08/06.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI
import RefreshableScrollView

class UserProfileViewModel: ObservableObject {
    
    let userUid : String
    @Published var currentProfileUser : User?
    @Published var profileUserPosts = [Post]()
    @Published var profileUserLikedPosts = [Post]()
    
    init(userUid: String) {
        self.userUid = userUid
        fetchUserPorifle()
        fetchUserPosts(userUid: userUid)
        fetchMyLikedPost(userUid: userUid)
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
        
        
        self.profileUserPosts.removeAll()
        
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
    
    
    func fetchMyLikedPostsUid(userUid: String, completion: @escaping(String) -> Void) {
        
        
        Firestore.firestore().collection("likes").document(userUid).collection("likes-posts").order(by: "postTime", descending: true).getDocuments { snapshot, error in
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
    
    func fetchMyLikedPost(userUid: String) {
        
        self.profileUserLikedPosts.removeAll()
        
        fetchMyLikedPostsUid(userUid: userUid) { postUid in
            
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
    @EnvironmentObject var vmAuth: AuthViewModel
    @State private var showChatMessages = false
    
    @State var showOptions = false
    
    init(userUid: String){
        self.userUid = userUid
        self.vm = UserProfileViewModel(userUid: userUid)
        
        
    }
    
    
    var body: some View {
        VStack {
            ScrollView {
                
                profileView
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle(vm.currentProfileUser?.name ?? "user name" )
                    .navigationBarItems(trailing:
                                            VStack{
                        
                        if self.userUid == (vmAuth.currentUser?.uid ?? "no uid") {
                            HStack{
                                Button {
                                    vm.fetchUserPosts(userUid: self.userUid)
                                    vm.fetchMyLikedPost(userUid: self.userUid)
                                } label: {
                                    Image(systemName: "arrow.up")
                                        .foregroundColor(Color.black)
                                }
                                
                                Spacer()
                                
                                Button {
                                    self.showOptions.toggle()
                                } label: {
                                    Image(systemName: "equal")
                                        .foregroundColor(Color.black)
                                }
                                .padding(.horizontal)
                            }
                        }
                    })
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
    
    private var profileView: some View {
        
        
        
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
                Text(vm.currentProfileUser?.profileText ?? "no profil text")
            }
            .padding(.horizontal)
            
            
            if self.userUid != (vmAuth.currentUser?.uid ?? "no uid") {
                Button {
                    self.showChatMessages.toggle()
                } label: {
                    Spacer()
                    Text("Chat")
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                        .padding(.vertical, 8)
                        
                    Spacer()
                    
                    NavigationLink("", isActive: $showChatMessages) {
                        ChatMessagesView(chatUser: vm.currentProfileUser, myUser: vmAuth.currentUser)
                    }
                }
                .background(Color.init(white: 0.7))
                .cornerRadius(10)
                .padding()
                
                
            }


            
            Divider()
            
            filterBar
            
            profilePostsview
            
            
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
                .environmentObject(AuthViewModel())
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
