//
//  PostsView.swift
//  InsutaguramuSwift
//
//  Created by 小暮準才 on 2022/07/31.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

class MainPostsViewModel: ObservableObject {
    @Published var posts = [Post]()
    
    init() {
        fetchPosts()
    }
    
    func fetchPosts() {
        
        posts.removeAll()
        
        Firestore.firestore().collection("posts").order(by: "time").getDocuments { snapshots, error in
            if let error = error {
                print(error)
                return
            }
            
            snapshots?.documents.forEach({ item in
                
                let docId = item.documentID
                let data = item.data()
                
                self.posts.insert(.init(documentId: docId, data: data), at: 0)
            })
        }
        
    }
    
}

struct MainPostsView: View {
    @ObservedObject var vm = MainPostsViewModel()
    
    var body: some View {
        NavigationView{
            ScrollView {
                VStack{
                    ForEach(vm.posts){ post in
                        PostView(nonCheckedPost: post)
                        
                        
                    }
                    
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading:
                                    VStack{
                Text("Insutaguramu")
                    .foregroundColor(Color.black)
                    .fontWeight(.heavy)
                
            })
            .navigationBarItems(trailing:
                                    VStack{
                Button {
                    vm.fetchPosts()
                } label: {
                    Text("fetch posts")
                        .foregroundColor(Color.black)
                        .fontWeight(.heavy)
                }
                
            })
        }
        
    }
    
    
    private var topNavBar : some View {
        HStack{
            Spacer()
            
            Text("title")
            
            Spacer()
            
        }
        .background(Color.gray)
    }
}

class PostViewModel: ObservableObject {
    
    @Published var post: Post
    
    
    
    //nothing check
    init(nonCheckedPost: Post){
        self.post = nonCheckedPost
        
        self.checkLikedOrNot(post: self.post) { didLiked in
            if didLiked == true {
                self.post.didLike = true
            }
        }
    }
    
    func likeThisPost(post: Post) {
        
        if post.didLike == true {
            return
        }
        
        guard let myUid = Auth.auth().currentUser?.uid else { return }
        let postId = post.documentId
        
        Firestore.firestore().collection("posts").document(postId).updateData(["likes": post.likes + 1 ]) { error  in
            if let error = error {
                print(error)
                return
            }
            
            let data = [
                "postUid": postId,
                "time": Date(),
                "postTime": post.time
            
            ] as [String:Any]
            
            Firestore.firestore().collection("likes").document(myUid).collection("likes-posts").document(postId).setData(data) { error2 in
                if let error2 = error2 {
                    print(error2)
                    return
                    
                }
                self.post.didLike = true
                self.post.likes += 1
            }
            
            
        }
        
    }
    
    func unlikeThisPost(post: Post) {
        
        if post.didLike == false {
            return
        }
        guard let myUid = Auth.auth().currentUser?.uid else { return }
        let postId = post.documentId
        guard post.likes > 0 else {
            print("post likes wrong")
            return }
        
        Firestore.firestore().collection("posts").document(postId).updateData(["likes": post.likes - 1 ]) { error in
            if let error = error {
                print(error)
                return
            }
            
            Firestore.firestore().collection("likes").document(myUid).collection("likes-posts").document(postId).delete() { _ in
                
                
                self.post.didLike = false
                self.post.likes += -1
                
            }
            
            
                
        }
        
       
    }
    
    //check whether you liked or not
    func checkLikedOrNot( post: Post, completion: @escaping(Bool)-> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let postId = post.documentId
        
        Firestore.firestore().collection("likes").document(uid).collection("likes-posts").document(postId).getDocument { snapshot, error in
            if let error = error {
                print(error)
                return
            }
            guard let snapshot = snapshot else { return }
            
            completion(snapshot.exists)
        }
    }
}

struct PostView: View {
    @ObservedObject var vm: PostViewModel
    @EnvironmentObject var vmAuth: AuthViewModel
    @State private var showMore = false
    @State private var showComments = false
    @State private var showProfile = false
    
    init(nonCheckedPost: Post){
        self.vm = PostViewModel(nonCheckedPost: nonCheckedPost)
    }
    
    var body: some View {
        LazyVStack{
            HStack{
                
                
                HStack{
                    ZStack{
                        WebImage(url: URL(string: vm.post.authorProfileUrl))
                            .resizable()
                            .background(Color.gray)
                            .frame(width: 35, height: 35)
                            .cornerRadius(100)
                            .zIndex(1)
                        
                        Image(systemName: "person")
                            .resizable()
                            .frame(width: 35, height: 35)
                            .background(Color.gray)
                            .cornerRadius(100)
                        
                    }
                    
                    Text(vm.post.authorName)
                        .fontWeight(.bold)
                        .foregroundColor(Color.black)
                    
                    Spacer()
                }
                .onTapGesture {
                    self.showProfile.toggle()
                }
                
                
                Image(systemName: "equal")
                
            }
            .padding(.horizontal)
            
            if vm.post.postImageUrl.count < 10 {
                WebImage(url: URL(string: "https://cdn.pixabay.com/photo/2016/11/23/00/44/arches-1851520_1280.jpg"))
                    .resizable()
                    .frame(width: 400, height: 400)
                    .scaledToFill()
                    .onTapGesture(count: 2) {
                        //click image and like button
                        if vm.post.didLike == false {
                            vm.likeThisPost(post: vm.post)
                        }
                    }
            } else {
                WebImage(url: URL(string: vm.post.postImageUrl))
                    .resizable()
                    .frame(width: 400, height: 400)
                    .scaledToFill()
                    .onTapGesture(count: 2) {
                        if vm.post.didLike == false {
                            vm.likeThisPost(post: vm.post)
                        }
                    }
            }
            
            HStack{
                //already liked
                if vm.post.didLike == true {
                    Button {
                        vm.unlikeThisPost(post: vm.post)
                    } label: {
                        Image(systemName: "heart.fill")
                            .foregroundColor(Color.red)
                    }
                    
                    //liked not yet
                } else {
                    Button {
                        vm.likeThisPost(post: vm.post)
                    } label: {
                        Image(systemName: "heart")
                            .foregroundColor(Color.black)
                    }
                }
                Text(vm.post.likes.description)
                Button {
                    self.showComments.toggle()
                } label: {
                    Image(systemName: "message")
                        .foregroundColor(Color.black)
                }
                


                Image(systemName: "paperplane")
                
                Spacer()
                
                Image(systemName: "bookmark")
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            
            if self.showMore == false {
                HStack(alignment: .bottom){
                    Text(vm.post.postText)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .lineLimit(1)
                    
                    if vm.post.postText.count > 30 && self.showMore == false {
                        Button {
                            self.showMore.toggle()
                        } label: {
                            Text("more...")
                                .foregroundColor(Color.gray)
                        }
                    }
                }
                
            } else {
                
                HStack(alignment: .bottom){
                    Text(vm.post.postText)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                }
                
            }
            
            HStack{
                Text(vm.post.time.dateValue(), style: .time)
                Text(vm.post.time.dateValue(), style: .date)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .foregroundColor(Color.gray)
            
            Divider()
            
        }
        
        
        //navigations
        NavigationLink("", isActive: $showComments) {
            PostCommentView(postUid: vm.post.id)
        }
        
        NavigationLink("", isActive: $showProfile) {
            UserProfileView(userUid: vm.post.authorUid)
        }
    }
}

struct PostsView_Previews: PreviewProvider {
    static var previews: some View {
        MainPostsView()
            .environmentObject(AuthViewModel())
    }
}
