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
    
    init(postUid: String){
        self.postUid = postUid
        fetchUserPorifle()
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
//        Firebase
        
    }
}

struct PostCommentView: View {
    
    let postUid : String
    @ObservedObject var vm : PostCommentViewModel
    
    init(postUid: String){
        self.postUid = postUid
        self.vm = PostCommentViewModel(postUid: postUid)
    }
    

    
//    let userUid: String?
    @State var commentText = ""
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
                            
                            
                            Text(vm.currentPost?.time.dateValue() ?? Date(), style: .date)
                            Text(vm.currentPost?.time.dateValue() ?? Date(), style: .time)
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                   
                    
                    Divider()
                    
                    Text("show comments")
                }
                .navigationBarTitle("Comments")
            }
            Spacer()
            
            HStack{
                Image(systemName: "person")
                    .resizable()
                    .frame(width: 35, height: 35)
                    .background(Color.gray)
                    .cornerRadius(100)
                
                TextField("hello ", text: $commentText)
                    .padding()
                    .background(Color.gray)
                Button {
                    print("dd")
                } label: {
                    Text("send")
                        .foregroundColor(Color.blue)
                }

            }
            .padding()
        }
        

    }
}

struct PostCommentView_Previews: PreviewProvider {
    static var previews: some View {
        PostCommentView(postUid: "216j9009psTjqnwBoHtD")
    }
}
