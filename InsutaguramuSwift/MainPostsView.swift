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
            .navigationTitle("main post")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing:
                                    VStack{
//                Button {
//                    print("hello")
//                } label: {
//                    Text("helli")
//                        .foregroundColor(Color.black)
//                }
                
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
    
    init(nonCheckedPost: Post){
        self.post = nonCheckedPost
        
    }
}

struct PostView: View {
    @ObservedObject var vm: PostViewModel
    
    init(nonCheckedPost: Post){
        self.vm = PostViewModel(nonCheckedPost: nonCheckedPost)
    }
    
    
    var body: some View {
        LazyVStack{
            HStack{
                
                Button {
                    print("show profile")
                } label: {
                    
                    ZStack{
                        WebImage(url: URL(string: vm.post.authorProfileUrl))
                            .resizable()
                            .background(Color.gray)
                            .frame(width: 35, height: 35)
                            .cornerRadius(100)
                            .zIndex(1)
                        
                        
                    }
                    
                    Text(vm.post.authorName)
                        .fontWeight(.bold)
                        .foregroundColor(Color.black)
                    
                    Spacer()
                }
                
                
                Image(systemName: "equal")
                
                
            }
            .padding(.horizontal)
            
            
            
            if vm.post.postImageUrl.count < 10 {
                WebImage(url: URL(string: "https://cdn.pixabay.com/photo/2016/11/23/00/44/arches-1851520_1280.jpg"))
                    .resizable()
                    .frame(width: 400, height: 400)
                    .scaledToFill()
            } else {
                WebImage(url: URL(string: vm.post.postImageUrl))
                    .resizable()
                    .frame(width: 400, height: 400)
                    .scaledToFill()
            }
            
            HStack{
                Button {
                    print("i love it")
                } label: {
                    Image(systemName: "heart")
                        .foregroundColor(Color.black)
                }
                
                Image(systemName: "message")
                Image(systemName: "paperplane")
                
                Spacer()
                
                Image(systemName: "bookmark")
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            
            
            HStack(alignment: .bottom){
                Text(vm.post.postText)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .lineLimit(2)
                
                if vm.post.postText.count > 30 {
                    Button {
                        print("show more")
                    } label: {
                        Text("more...")
                            .foregroundColor(Color.gray)
                    }
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
    }
    
    
    
}

struct PostsView_Previews: PreviewProvider {
    static var previews: some View {
        MainPostsView()
    }
}
