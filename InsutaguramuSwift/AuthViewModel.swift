//
//  AuthViewModel.swift
//  InsutaguramuSwift
//
//  Created by 小暮準才 on 2022/07/31.
//

import SwiftUI
import Firebase
import FirebaseAuth



class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var didRegistration = false
    private var tempUserSession : FirebaseAuth.User?
    
    @Published var errorMessage = "error message desu"
    
    init() {
        self.userSession = Auth.auth().currentUser
        self.fetchUserData()
    }
    
    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) {
            result, error in
            if let error = error {
                print(error)
                return
            }
            guard let user = result?.user else { return }
            self.userSession = user
            self.errorMessage = "login done"
            
            self.fetchUserData()
            
            
            
            
        }
    }
    
    func storeProfileImage(profileImage: UIImage, completion: @escaping(Bool)-> Void) {
        
        self.errorMessage = "storing profile image"
        
        guard let myUid = tempUserSession?.uid else {
            self.errorMessage = "no user"
            return }
        
        let ref = Storage.storage().reference(withPath: "profile/" + myUid)
        
        guard let imageData = profileImage.jpegData(compressionQuality: 0.5) else {
            self.errorMessage = "no profile image i dont know"
            return }
        self.errorMessage = "putdata"
        ref.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print(error)
                self.errorMessage = "\(error)"
                return
            }
            self.errorMessage = "download url"
            ref.downloadURL { url, error in
                if let error = error {
                    print(error)
                    self.errorMessage = "\(error)"
                    return
                }
//
                self.errorMessage = "download url done \(url?.absoluteString ?? "no url")"
                
                guard let profileImageUrl = url?.absoluteString else {
                    self.errorMessage = "url error"
                    return }
//
//                self.errorMessage = profileImageUrl.description
//
                self.errorMessage = profileImageUrl
                
                Firestore.firestore().collection("users").document(myUid).updateData(["profileImageUrl": profileImageUrl ]) { error in
                    if let error = error {
                        print(error)
                        self.errorMessage = "\(error)"
                        return
                    }
                    self.errorMessage = "stored profile image"
                    
                    completion(true)
//
                }
            }
        }
        
        
            
        
    }
    
    func fetchUserData() {
        
        self.errorMessage = "1"
        
        guard let myUid = self.userSession?.uid else {
            print("no userssion uid")
            return }
        
        Firestore.firestore().collection("users").document(myUid).getDocument { snapshot, error in
            if let error = error {
                print(error)
                return
            }
            self.errorMessage = "2"
            guard let documentId = snapshot?.documentID else {
                self.errorMessage = "no document"
                return }
            guard let data = snapshot?.data() else {
                self.errorMessage = "no data"
                return }
            
            self.currentUser = User(documentId: documentId, data: data)
            self.errorMessage = "user fetch done"
            print("fetched current usedata")
        }
    }
    
    func logOut() {

        try? Auth.auth().signOut()
        self.userSession = nil
        self.currentUser = nil
        self.errorMessage = "logout done"
    }
    
    func register(email: String, password: String, name: String, profileImage: UIImage, completion: @escaping(Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print(error)
                self.errorMessage = "\(error)"
                return
            }
            
            guard let user = result?.user else { return }
            self.tempUserSession = user
            
            let newUserData = [
                "email": email,
                "name":name,
                "uid": user.uid,
                "joinDate": Date(),
                "profileImageUrl" : "",
                "profileText" : "",
            ] as [String: Any]
            
            Firestore.firestore().collection("users").document(user.uid).setData(newUserData){ error in
                if let error = error {
                    print(error)
                    return
                }
                

            }
            
            self.storeProfileImage(profileImage: profileImage) { didStoredImage in
                if didStoredImage == true {
                    self.errorMessage = "success to register"
                    
                    sleep(2)
                    
                    self.errorMessage = ""
                    completion(true)
                }
            }
            
            
        }
    }
    
    
    
    
}
