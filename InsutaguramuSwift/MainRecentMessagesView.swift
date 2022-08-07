//
//  RecentMessagesView.swift
//  InsutaguramuSwift
//
//  Created by 小暮準才 on 2022/08/07.
//

import SwiftUI
import Firebase

struct RecentMessage: Identifiable, Codable {
    
    var id: String {documentId}
    
    let documentId: String
    let uid, name, email, profileImageUrl, recentText: String
    let time: Timestamp
    
    init(documentId: String, data: [String:Any]) {
        self.documentId = documentId
        self.uid = data["uid"] as? String ?? "no"
        self.email = data["email"] as? String ?? "no email"
        self.name = data["name"] as? String ?? "no name"
        self.profileImageUrl = data["profileImageUrl"] as? String ?? "no profileImageUrl"
        self.recentText = data["recentText"] as? String ?? "no recentText"
        self.time = data["time"] as? Timestamp ?? Timestamp()
    }
    
    
}

struct MainRecentMessagesView: View {
    var body: some View {
        ScrollView{
            LazyVStack(alignment: .leading){
                ForEach(0..<5){ recentMessage in
                    RecentMessageView()

                    
                }
            }
        }
        .navigationTitle("recent Messages")
        .navigationBarTitleDisplayMode(.inline)
    }
}


class RecentMessageViewModel: ObservableObject{
    
    
}

struct RecentMessageView: View{
    var body: some View{
        HStack{
            Image(systemName: "person")
                .resizable()
                .frame(width: 35, height: 35)
                .background(Color.gray)
                .cornerRadius(100)
            
            VStack(alignment: .leading){
                Text("name")
                    .fontWeight(.bold)
                Text("recentMessage")
                
            }
            
            Spacer()
            
            Text("time")
                .foregroundColor(Color.gray)
        }
        .padding(.horizontal)
        .onTapGesture {
            print("show messages")
        }
    }
}

struct RecentMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            MainRecentMessagesView()
        }
    }
}
