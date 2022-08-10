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
    
    var chatUser : User?
    
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


class MainRecentMessagesViewModel: ObservableObject {
    
    @Published var recentMessages = [RecentMessage]()
    
    @Published var myUser: User?
    
    init() {
        self.fetchCurrentUser {
            self.fetchRecentMessages()
        }
        
    }
    
    func fetchCurrentUser(completion: @escaping ()->()) {
        guard let myUid = Auth.auth().currentUser?.uid else { return  }
        
        Firestore.firestore().collection("users").document(myUid).getDocument { snapshot, error in
            if let error = error {
                print(error)
                return
            }
            
            guard let documentId = snapshot?.documentID else { return }
            guard let data = snapshot?.data() else { return }
            
        
            
            self.myUser = User(documentId: documentId, data: data)
            
            completion()
        }
        
    }
    
    
    func fetchRecentMessages() {
        // get rm
        
//        self.recentMessages.removeAll()
        
        guard let user = self.myUser else { return }
        
        Firestore.firestore().collection("recentMessages").document(user.uid).collection("recentMessages").getDocuments { snapshots, error in
            if let error = error {
                print(error)
                return
            }
            
            snapshots?.documents.forEach({ doc in
                let documentId = doc.documentID
                let data = doc.data()
                
                self.recentMessages.insert(.init(documentId: documentId, data: data), at: 0)
                
                Firestore.firestore().collection("users").document(self.recentMessages[0].uid).getDocument { usersnapshot , error in
                    if let error2 = error {
                        print(error2)
                        return
                    }
                    
                    
                    guard let userId = usersnapshot?.documentID else { return }
                    guard let userData = usersnapshot?.data() else { return }
                    
                    self.recentMessages[0].chatUser = User(documentId: userId, data: userData)
                }
                
            })
            
            
           
        }
    }
    
    func fetchRecentMessagesProfile() {
        // get user profiles
    }
    
}

struct MainRecentMessagesView: View {
    
    @EnvironmentObject var vmAuth: AuthViewModel
    
    @ObservedObject var vm = MainRecentMessagesViewModel()
    
    

    
    var body: some View {
        ScrollView{
            LazyVStack(alignment: .leading){
                Text(vm.myUser?.uid ?? "no uid")
                
                Button {
                    vm.fetchRecentMessages()
                } label: {
                    Text("fetch recentMessages")
                }

                ForEach(vm.recentMessages){ recentMessage in
                    RecentMessageView(recentMessage: recentMessage)

                    
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}


class RecentMessageViewModel: ObservableObject{
    
    
    
    
}

struct RecentMessageView: View{
    @EnvironmentObject var vmAuth: AuthViewModel
    let recentMessage : RecentMessage
    @State var showChatMessages = false
    
    init(recentMessage: RecentMessage) {
        self.recentMessage = recentMessage
    }
    var body: some View{
        HStack{
            Image(systemName: "person")
                .resizable()
                .frame(width: 35, height: 35)
                .background(Color.gray)
                .cornerRadius(100)
            
            VStack(alignment: .leading){
                Text(recentMessage.name)
                    .fontWeight(.bold)
                Text(recentMessage.recentText)
                
            }
            
            Spacer()
            
            Text(recentMessage.time.dateValue(), style: .time)
                .foregroundColor(Color.gray)
        }
        .padding(.horizontal)
        .onTapGesture {
            self.showChatMessages.toggle()
        }
        
        NavigationLink("", isActive: $showChatMessages) {
            ChatMessagesView(chatUser: recentMessage.chatUser, myUser: vmAuth.currentUser)
        }
    }
}

struct RecentMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            MainRecentMessagesView()
                .environmentObject(AuthViewModel())
        }
    }
}
