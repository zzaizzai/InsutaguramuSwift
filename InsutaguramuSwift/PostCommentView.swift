//
//  PostCommentView.swift
//  InsutaguramuSwift
//
//  Created by 小暮準才 on 2022/08/06.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI




class PostCommentViewModel: ObservableObject {
    
    @Published var postUid: String
    @Published var profileUser: User?
    @Published var currentPost: Post?
    @Published var comments = [Comment]()
    
    init(postUid: String){
        self.postUid = postUid
        fetchUserPorifle()
        fetchComments()
    }
    
    func fetchUserPorifle() {
        Firestore.firestore().collection("posts").document(self.postUid).getDocument { snapshot, error in
            if let error = error {
                print(error)
                return
            }
            
            guard let data = snapshot?.data() else { return }
            guard let documentId = snapshot?.documentID else { return }
            
            self.currentPost = Post(documentId: documentId, data: data)
            
            
        }
    }
    
    func fetchCurrentPost() {
        
    }
    
    func fetchComments() {
        
        self.comments.removeAll()
        
        Firestore.firestore().collection("posts").document(self.postUid).collection("comments").order(by: "time").getDocuments { snpashot, error in
            if let error = error {
                print(error)
                return
            }
            
            snpashot?.documents.forEach({ doc in
                let documentId = doc.documentID
                let data = doc.data()
                
                self.comments.append(.init(documentId: documentId, data: data))
                
            })
            
        }
        
    }
    
    func writeComment(text: String, currentUser: User?, completion: @escaping(Bool)->()){
        
        guard let myUser = currentUser else { return }
        
        let commentData = [
            "text": text,
            "time": Date(),
            "postUid": self.postUid,
            "commentUserUid": myUser.uid,
            "commentUserName": myUser.name,
            "commentUserProfileUrl": myUser.profileImageUrl,
            
        ] as [String:Any]
        
        Firestore.firestore().collection("posts").document(self.postUid).collection("comments").document().setData(commentData) { error in
            if let error = error {
                print(error)
                return
            }
            
            completion(true)
        }
        
        
    }
}

struct PostCommentView: View {
    
    let postUid : String
    @ObservedObject var vm : PostCommentViewModel
    @EnvironmentObject var vmAuth: AuthViewModel
    
    
    init(postUid: String){
        self.postUid = postUid
        self.vm = PostCommentViewModel(postUid: postUid)
    }
    

    
//    let userUid: String?
    @State var commentText = ""
    @FocusState private var commentFocused : Bool
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    HStack{
                        ZStack{
                            WebImage(url: URL(string: vm.currentPost?.authorProfileUrl ?? ""))
                                .resizable()
                                .background(Color.gray)
                                .frame(width: 50, height: 50)
                                .cornerRadius(100)
                                .zIndex(1)
                            
                            Image(systemName: "person")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .background(Color.gray)
                                .cornerRadius(100)
                            
                        }
                        VStack(alignment: .leading ){
                            Text(vm.currentPost?.authorName ?? "name")
                                .fontWeight(.bold)
                            Text(vm.currentPost?.postText ?? "text")
                            
                            Text("")
                            
                            
                            HStack{
                                Text(vm.currentPost?.time.dateValue() ?? Date(), style: .date)
                                Text(vm.currentPost?.time.dateValue() ?? Date(), style: .time)
                                
                            }
                            .foregroundColor(Color.gray)
                            
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                   
                    
                    Divider()
                    
                    ForEach(vm.comments) { comment in
                        LazyVStack(alignment: .leading){
                            HStack(alignment: .top){
                                
                               ZStack{
                                    
                                    WebImage(url: URL(string: comment.commentUserProfileUrl))
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
                                
                                VStack(alignment: .leading){
                                    Text(comment.commentUserName)
                                        .fontWeight(.bold)
                                    Text(comment.text)
                                    HStack{
                                        Text(comment.time.dateValue(), style: . time)
                                        Text(comment.time.dateValue(), style: . date)
                                    }
                                    .foregroundColor(Color.gray)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .navigationBarTitle("Comments")
            }
            Spacer()
            
            HStack{
                ZStack{
                    
                    WebImage(url: URL(string: vmAuth.currentUser?.profileImageUrl ?? ""))
                        .resizable()
                        .background(Color.gray)
                        .frame(width: 50, height: 50)
                        .cornerRadius(100)
                        .zIndex(1)
                    
                    
                    Image(systemName: "person")
                        .resizable()
                        .frame(width: 35, height: 35)
                        .background(Color.gray)
                        .cornerRadius(100)
                }
                
                TextField("hello ", text: $commentText)
                    .focused($commentFocused)
                    .autocapitalization(.none)
                    .padding()
                    .background(Capsule().fill(Color.init(white: 0.9)))
                    .padding()
                
                Button {
                    commentFocused = false
                    vm.writeComment(text: self.commentText, currentUser: vmAuth.currentUser) { didWrite in
                        if didWrite == true {
                            self.commentText  = ""
                            vm.fetchComments()
                        }
                    }
                } label: {
                    Text("write")
                        .foregroundColor(Color.blue)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct PostCommentView_Previews: PreviewProvider {
    static var previews: some View {
        PostCommentView(postUid: "216j9009psTjqnwBoHtD")
            .environmentObject(AuthViewModel())
    }
}
