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
        userSession = nil
        try? Auth.auth().signOut()
        self.errorMessage = "logout done"
    }
    
    func register(email: String, password: String, name: String) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print(error)
                return
            }
            
            guard let user = result?.user else { return }
            
            let newUserData = [
                "email": email,
                "name":name,
                "uid": user.uid,
                "joinDate": Date()
            ] as [String: Any]
            
            Firestore.firestore().collection("users").document(user.uid).setData(newUserData){ error in
                if let error = error {
                    print(error)
                    return
                }
                
                self.didRegistration = true
                self.errorMessage = "registration done"
            }
            
            
        }
    }
    
    
    
    
}
