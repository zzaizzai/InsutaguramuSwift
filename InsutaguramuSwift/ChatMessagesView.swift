//
//  ChatMessagesView.swift
//  InsutaguramuSwift
//
//  Created by 小暮準才 on 2022/08/08.
//

import SwiftUI
import Firebase

struct ChatMessage: Identifiable {
    var id : String { documentId }
    
    let documentId: String
    let fromId, toId, text: String
    
    let time: Timestamp
    
    
}

class ChatMessagesViewModel: ObservableObject {
    
    @Published var chatText = "chat text"
    
    
    
    func sendChatMessage (myUser: User?) {
        
        guard let myUserData = myUser else { return }
        
        
        let recentChatdataInMyDB = [
            "uid" :  "xZryzy2r0YeKAHrQCuoprzDR5nO2",
            "email": "test2@test.com",
            "name": "Tomas",
            "profileImageUrl": "profileImageUrl",
            "recentText" : self.chatText,
            "time" : Date(),
            
        ] as [String:Any]
        
        let chatDataInMyDB = [
            "fromId" : "Akct8DqUtdZJYCc9yn2UojJqlNY2",
            "toId" : "xZryzy2r0YeKAHrQCuoprzDR5nO2",
            "text" : self.chatText,
            "time" : Date(),
            
        ] as [String:Any]
        
        
        //Chat Messages in my DB
        Firestore.firestore().collection("messages").document(myUserData.uid).collection("xZryzy2r0YeKAHrQCuoprzDR5nO2").document().setData(chatDataInMyDB) { error in
            if let error = error {
                print(error)
                return
            }
            
            //Recent Messages in my DB
            Firestore.firestore().collection("recentMessages").document(myUserData.uid).collection("recentMessages").document("xZryzy2r0YeKAHrQCuoprzDR5nO2").setData(recentChatdataInMyDB) { error in
                if let error2 = error {
                    print(error2)
                    return
                }
            }
        }
        
        
        
        
        self.chatText = ""
        
    }
}


struct ChatMessagesView: View {
    
    let opponentUid: String
    
    @EnvironmentObject var vmAuth: AuthViewModel
    
    @ObservedObject var vm = ChatMessagesViewModel()
    
    
    
    var body: some View {
        ZStack {
            ScrollView{
                
                ForEach(0..<5) { message in
                    MessageView()
                    
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
            Image(systemName: "person")
                .resizable()
                .frame(width: 35, height: 35)
                .background(Color.gray)
                .cornerRadius(100)
            
            Text("user name")
            
        })
        
        
    }
    
    private var bottomView: some View {
        
        HStack{
            Button {
                print("photo")
            } label: {
                Image(systemName: "photo")
                    .foregroundColor(Color.black)
            }
            
            TextField("Eenter messages....", text: $vm.chatText)
                .autocapitalization(.none)
            
            if vm.chatText.count > 0 {
                
                Button {
                    vm.sendChatMessage(myUser: vmAuth.currentUser)
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
    var body: some View{
        HStack{
            Spacer()
            
            Text("AM 3:00")
                .foregroundColor(Color.gray)
            
            Text("message")
                .foregroundColor(Color.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(30)
        }
        .padding(.horizontal)
        
        
    }
}

struct ChatMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            ChatMessagesView(opponentUid: "123")
                .environmentObject(AuthViewModel())
        }
    }
}
