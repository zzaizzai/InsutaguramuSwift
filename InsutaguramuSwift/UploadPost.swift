//
//  UploadPost.swift
//  InsutaguramuSwift
//
//  Created by 小暮準才 on 2022/08/01.
//

import SwiftUI
import Firebase



class UploadPostViewModel: ObservableObject {
    
    
    @Published var errorMessage = "error"
    
    
    func uploadPost(uploadText: String, uploadImage:UIImage , currentUser: User, completion: @escaping (Bool)-> Void) {
        
        if uploadText.count < 5 {
            self.errorMessage = "more than 4 characters"
            return
        }
        
        let uploadPostData = [
            "authorUid" : currentUser.uid,
            "authorEmail" : currentUser.email,
            "authorName" : currentUser.name,
            "authorProfileUrl" : currentUser.profileImageUrl,
            "postText" : uploadText,
            "postImageUrl": "",
            "likes" : 0,
            "time" : Date(),
            "didLike": false,
        ] as [String:Any]
        
        var storeRef: DocumentReference?
        storeRef = Firestore.firestore().collection("posts").addDocument(data: uploadPostData) { error in
            if let error = error {
                print(error)
                return
            }
            guard let docId = storeRef?.documentID else {
                print("no doc id")
                return }
            let ref = Storage.storage().reference(withPath: "posts/\(docId)")
            self.errorMessage = "upload done"
            
            
            guard let imageData = uploadImage.jpegData(compressionQuality: 0.5) else {
                self.errorMessage = "no image"
                return }
            
            
            ref.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print(error)
                    return
                }
                ref.downloadURL { URL, error in
                    if let error = error {
                        print(error)
                        return
                    }
                    
                    self.errorMessage = "\(URL?.absoluteString ?? "no url")"
                    
                    guard let uploadImageUrl = URL?.absoluteString else { return }
                    
                    
                    Firestore.firestore().collection("posts").document(docId).updateData(["postImageUrl": uploadImageUrl]) { error in
                        if let error = error {
                            print(error)
                            return
                        }
                        
                        self.errorMessage = "store image done"
                        completion(true)
                    }
                }
            }
        }
    }
}

struct UploadPost: View {
    
    @EnvironmentObject var vmAuth: AuthViewModel
    
    @ObservedObject var vm = UploadPostViewModel()
    @State var uploadText: String = ""
    @State var uploadImage: UIImage?
    @State private var showImagePicker = false
    
    
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
                    
                    if self.uploadImage == nil || self.uploadText.count < 5 {
                        Text("upload")
                            .padding()
                            .foregroundColor(Color.gray)
                            .background(Color.black)
                            .cornerRadius(30)
                    } else {
                        Button {
                            vm.uploadPost(uploadText: self.uploadText, uploadImage: self.uploadImage! , currentUser: vmAuth.currentUser!){ didUpload in
                                if didUpload == true {
                                    self.uploadImage = nil
                                    self.uploadText = ""
                                }
                            }
                            
                        } label: {
                            Text("upload")
                                .foregroundColor(Color.white)
                        }
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(30)
                    }
                    
                }
                .padding(.horizontal)
                
                Text(vmAuth.currentUser?.name  ?? "no username")
                
                Divider()
                
                ZStack(alignment: .top){
                    TextEditor(text: $uploadText)
                        .padding()
                        .background(Color.gray)
                        .frame(width: .infinity, height: 200)
                    
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
                
                Button {
                    self.showImagePicker.toggle()
                } label: {
                    if let uploadImage = uploadImage {
                        Image(uiImage: uploadImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: .infinity, height: 400, alignment: .center)
                            .scaledToFill()
                        
                    } else {
                        Image(systemName: "photo")
                            .font(.system(size: 120))
                            .foregroundColor(Color.black)
                            .padding()
                    }
                }
                
                Spacer()
                
            }
        }
        .fullScreenCover(isPresented: $showImagePicker) {
            ImagePicker(image: $uploadImage)
        }
        
    }
}

struct UploadPost_Previews: PreviewProvider {
    static var previews: some View {
        UploadPost()
            .environmentObject(AuthViewModel())
    }
}
