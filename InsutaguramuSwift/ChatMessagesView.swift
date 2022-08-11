//
//  ChatMessagesView.swift
//  InsutaguramuSwift
//
//  Created by 小暮準才 on 2022/08/08.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI





class ChatMessagesViewModel: ObservableObject {
    
    var myUser: User?
    var chatUser: User?
    
    @Published var chatText = ""
    @Published var chatMessages = [ChatMessage]()
    
    init(chatUser: User?, myUser: User?) {
        self.chatUser = chatUser
        self.myUser = myUser
        
        self.fetchChatMessages()
    }
    
    
    
    func fetchChatMessages () {
        
        guard let myUid = self.myUser?.uid else { return }
        guard let chatUserUid = self.chatUser?.uid else { return }
        
        Firestore.firestore().collection("messages").document(myUid).collection(chatUserUid).order(by: "time").getDocuments { snapshots, error in
            if let error = error {
                print(error)
                return
            }
            
            snapshots?.documents.forEach({ doc in
                let documentId = doc.documentID
                let data = doc.data()
                
                self.chatMessages.append(.init(documentId: documentId, data: data))
                
                
                
                
            })
        }
        
    }
    
    
    func sendChatMessage () {
        
        guard let myUserData = self.myUser else { return }
        guard let chatUserData = self.chatUser else { return }
        
        
        //common Data
        let chatData = [
            "fromId" : myUserData.id,
            "toId" : chatUserData.id,
            "text" : self.chatText,
            "time" : Date(),
        ] as [String:Any]
        
        
        //DB myUser
        let recentChatdataInMyDB = [
            "uid" :  chatUserData.uid,
            "email": chatUserData.email,
            "name": chatUserData.name,
            "profileImageUrl": chatUserData.profileImageUrl,
            "recentText" : self.chatText,
            "time" : Date(),
        ] as [String:Any]
        
        //Chat Messages in my DB
        Firestore.firestore().collection("messages").document(myUserData.uid).collection(chatUserData.uid).document().setData(chatData) { error in
            if let error = error {
                print(error)
                return
            }
            
            //Recent Messages in my DB
            Firestore.firestore().collection("recentMessages").document(myUserData.uid).collection("recentMessages").document(chatUserData.uid).setData(recentChatdataInMyDB) { error in
                if let error2 = error {
                    print(error2)
                    return
                }
            }
        }
        
        //DB chatUser
        let recentChatdataInChatUserDB = [
            "uid" :  myUserData.uid,
            "email": myUserData.email,
            "name": myUserData.name,
            "profileImageUrl": myUserData.profileImageUrl,
            "recentText" : self.chatText,
            "time" : Date(),
        ] as [String:Any]
        
        //Chat Messages in chatUser DB
        Firestore.firestore().collection("messages").document(chatUserData.uid).collection(myUserData.uid).document().setData(chatData) { error in
            if let error = error {
                print(error)
                return
            }
            
            //Recent Messages in chatUser DB
            Firestore.firestore().collection("recentMessages").document(chatUserData.uid).collection("recentMessages").document(myUserData.uid).setData(recentChatdataInChatUserDB) { error2 in
                if let error2 = error2{
                    print(error2)
                    return
                }
            }
        }
        
        
        
        
        
        self.chatText = ""
        
    }
}


struct ChatMessagesView: View {
    
    
    
    @ObservedObject var vm : ChatMessagesViewModel
    @EnvironmentObject var vmAuth: AuthViewModel
    
    init(chatUser: User?, myUser: User?){
        self.vm = .init(chatUser: chatUser, myUser: myUser)
        
    }
    
    
    var body: some View {
        
        ZStack {
            ScrollView{
                Button {
                    //                    vm.fetchChatMessages()
                } label: {
                    Text("fetchChat")
                }
                
                ForEach(vm.chatMessages) { message in
                    MessageView(chatMessage: message)
                    
                }
                
                
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
        .safeAreaInset(edge: .bottom) {
            
            bottomView
            
            
        }
        .navigationBarItems(leading:
                                HStack{
            ZStack{
                
                WebImage(url: URL(string: vm.chatUser?.profileImageUrl ?? "no url"))
                    .resizable()
                    .frame(width: 35, height: 35)
                    .background(Color.gray)
                    .cornerRadius(100)
                    .zIndex(1)
                
                
                Image(systemName: "person")
                    .resizable()
                    .frame(width: 35, height: 35)
                    .background(Color.gray)
                    .cornerRadius(100)
                
            }
            
            
            Text(vm.chatUser?.name ?? "no name")
                .fontWeight(.bold)
            
        })
        
        
    }
    
    private var bottomView: some View {
        
        HStack{
            Button {
                print("photo")
            } label: {
                WebImage(url: URL(string: vm.myUser?.profileImageUrl ?? "no url"))
                    .resizable()
                    .frame(width: 35, height: 35)
                    .background(Color.gray)
                    .cornerRadius(100)
                    .zIndex(1)
            }
            
            TextField("Eenter messages....", text: $vm.chatText)
                .padding()
                .background(Color.init(white: 0.85))
                .cornerRadius(30)
                .autocapitalization(.none)
            
            if vm.chatText.count > 0 {
                
                Button {
                    vm.sendChatMessage()
                } label: {
                    Text("send")
                        .foregroundColor(Color.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(20)
                }
            } else {
                Button {
                    
                } label: {
                    Text("send")
                        .foregroundColor(Color.gray)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(20)
                }
            }
            
        }
        .padding()
        
    }
    
    
}


struct MessageView: View {
    
    let chatMessage : ChatMessage
    
    
    var body: some View{
        VStack{
            if chatMessage.fromId == Auth.auth().currentUser?.uid {
                HStack{
                    Spacer()
                    
                    Text(chatMessage.time.dateValue(), style: .time)
                        .foregroundColor(Color.gray)
                    
                    Text(chatMessage.text)
                        .foregroundColor(Color.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(30)
                }
                .padding(.horizontal)
                
            } else {
                HStack{
                    
                    Text(chatMessage.text)
                        .foregroundColor(Color.white)
                        .padding()
                        .background(Color.init(red: 0.2, green: 0.7, blue: 0.5))
                        .cornerRadius(30)
                    
                    Text(chatMessage.time.dateValue(), style: .time)
                        .foregroundColor(Color.gray)
                    
                    Spacer()
                }
                .padding(.horizontal)
                
            }
        }
        
    }
}

struct ChatMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            MainRecentMessagesView()
                .environmentObject(AuthViewModel())
        }
    }
}

//struct ChatMessagesView_Previews: PreviewProvider {
//    private var chatvm = ChatMessagesViewModel(myUser: nil, chatUser: nil)
//    static var previews: some View {
//        NavigationView{
//            ChatMessagesView(vm: chatvm)
//                .environmentObject(AuthViewModel())
//        }
//    }
//}
