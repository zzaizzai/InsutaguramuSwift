//
//  PostsView.swift
//  InsutaguramuSwift
//
//  Created by 小暮準才 on 2022/07/31.
//

import SwiftUI
import SDWebImageSwiftUI

class MainPostsViewModel: ObservableObject {
    @Published var posts = [Post]()
    
}

struct MainPostsView: View {
    var body: some View {
        ScrollView {
            VStack{
                ForEach(0..<3){ item in
                    PostView()
                    
                }
                
            }
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

struct PostView: View {
    var body: some View {
        LazyVStack{
            HStack{
                Image(systemName: "person")
                    .resizable()
                    .background(Color.gray)
                    .frame(width: 30, height: 30)
                    .cornerRadius(100)
                
                Text("name")
                    .fontWeight(.bold)
                
                Spacer()
                
                Image(systemName: "equal")
                
               
            }
            .padding(.horizontal)
            
            WebImage(url: URL(string: "https://cdn.pixabay.com/photo/2017/01/18/16/46/hong-kong-1990268_1280.jpg"))
                .resizable()
                .frame(width: 400, height: 400)
                .scaledToFill()
            
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
                Text("i love this city. as you can see, it is very important thing that seeing the building s lighting ver beuatifully ")
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .lineLimit(2)
                
                Button {
                    print("show more")
                } label: {
                    Text("more...")
                        .foregroundColor(Color.gray)
                }

            }
        
            
            
            
            Divider()
            
        }
    }
    

    
}

struct PostsView_Previews: PreviewProvider {
    static var previews: some View {
            MainPostsView()
    }
}
