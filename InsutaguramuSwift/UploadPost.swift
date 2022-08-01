//
//  UploadPost.swift
//  InsutaguramuSwift
//
//  Created by 小暮準才 on 2022/08/01.
//

import SwiftUI
import Firebase

struct Post: Identifiable {
    
    var id : String { documentId }
    
    let documentId: String
    let authorUid, text : String
    let authorName, authorEmail, authorProfileUrl : String
    let time: Date
    var likes: Int
    
    var didLike: Bool? = false
}

class UploadPostViewModel: ObservableObject {
    @Published var errorMessage = "error"
    
    
    func uploadPost(uploadText: String, currentUser: User) {
        
        if uploadText.count < 5 {
            self.errorMessage = "more than 4 characters"
            return
        }
        
        let uploadPostData = [
            "authorUid" : currentUser.uid,
            "authorEmail" : currentUser.email,
            "authorName" : currentUser.name,
            "authorProfileUrl" : currentUser.profileImageUrl,
            "text" : uploadText,
            "likes" : 0,
            "time" : Date(),
            "didLike": false,
        ] as [String:Any]
        
        Firestore.firestore().collection("posts").document().setData(uploadPostData) { error in
            if let error = error {
                print(error)
                return
            }
            
            self.errorMessage = "upload done"
        }
        
    }
    
}

struct UploadPost: View {
    
    @EnvironmentObject var vmAuth: AuthViewModel
    
    @ObservedObject var vm = UploadPostViewModel()
    @State var uploadText: String = ""
    
    
    var body: some View {
        VStack {
            VStack{
                
                HStack{
                    Button {
                        print("dd")
                    } label: {
                        Text("cancle")
                    }
                    Spacer()
                    Text(vm.errorMessage)
                    Spacer()
                    
                    Button {
                        vm.uploadPost(uploadText: self.uploadText, currentUser: vmAuth.currentUser!)
                        self.uploadText = ""
                    } label: {
                        Text("upload")
                            .foregroundColor(Color.white)
                    }
                    .padding()
                    .background(Color.gray)
                    .cornerRadius(30)
                }
                .padding(.horizontal)
                
                Text(vmAuth.currentUser?.name  ?? "no username")
                
                Divider()
                
                ZStack(alignment: .top){
                    TextEditor(text: $uploadText)
                        .padding()
                        .background(Color.gray)
                    
                    if self.uploadText.isEmpty {
                        
                        HStack{
                            Text("share your things")
                                .foregroundColor(Color.gray)
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                            Spacer()
                        }
                        .padding()
                        
                        
                    }
                }
            }
        }
    }
}

struct UploadPost_Previews: PreviewProvider {
    static var previews: some View {
        UploadPost()
            .environmentObject(AuthViewModel())
    }
}