//
//  ProfileView.swift
//  InsutaguramuSwift
//
//  Created by 小暮準才 on 2022/07/31.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseFirestore


struct PostUid: Identifiable, Codable {
    
    var id : String { documentId }
    
    let documentId: String
    let postUid : String
    let time: Timestamp
    let postTime: Timestamp
    
    
    init(documentId: String, data: [String:Any] ) {
        self.documentId = documentId
        self.postUid = data["authorUid"] as? String ?? "no authorUid"
        
        self.time = data["time"] as? Timestamp ?? Timestamp()
        self.postTime = data["postTime"] as? Timestamp ?? Timestamp()
    }
}


class ProfileViewModel: ObservableObject{
    @Published var myPosts = [Post]()
    @Published var myLikedPostsUid = [PostUid]()
    @Published var myLikedPosts = [Post]()
    
    
    
    init(){
        
        fetchMyPosts()
        fetchMyLikedPostsUid()
    }
    
    func fetchMyPosts() {
        
        guard let myUid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("posts").whereField("authorUid",isEqualTo: myUid).order(by: "time").getDocuments { snapsnots, error in
            if let error = error {
                print(error)
                return
            }
            
            snapsnots?.documents.forEach({ doc in
                
                let data = doc.data()
                let documentId = doc.documentID
                
                self.myPosts.insert(.init(documentId: documentId, data: data), at: 0)
                
            })
        }
    }
    
    func fetchMyLikedPostsUid() {
        guard let myUid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("likes").document(myUid).collection("likes-posts").order(by: "postTime").getDocuments { snapshot, error in
            if let error = error {
                print(error)
                return
            }
            
            snapshot?.documents.forEach({ doc in
                let data = doc.data()
                let documentId = doc.documentID
                
                self.myLikedPostsUid.insert(.init(documentId: documentId, data: data), at: 0)
                
                self.fetchMyLikedPost(postUid: documentId)
                
            })
            
        }
        
        
    }
    
    func fetchMyLikedPost(postUid: String) {
        
        Firestore.firestore().collection("posts").document(postUid).getDocument { snapshot, error in
            if let error = error {
                print(error)
                return
            }
            
            guard let data = snapshot?.data() else { return }
            guard let documentId = snapshot?.documentID else { return }
            
            self.myLikedPosts.append(.init(documentId: documentId, data: data))
            
            
            
            
        }
        
    }
}

struct ProfileView: View {
    @EnvironmentObject var vmAuth : AuthViewModel
    
    @ObservedObject var vm = ProfileViewModel()
    
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
                                
                                Text(vm.myPosts.count.description)
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
                    ForEach(vm.myPosts){ post in
                        PostView(nonCheckedPost: post)

                    }
                }
            } else {
                VStack{
                    ForEach(vm.myLikedPosts){ likedpost in
                        PostView(nonCheckedPost: likedpost)
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
