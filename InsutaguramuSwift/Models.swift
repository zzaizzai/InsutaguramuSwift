//
//  Models.swift
//  InsutaguramuSwift
//
//  Created by 小暮準才 on 2022/07/31.
//

import Foundation
import FirebaseFirestoreSwift
import Firebase


struct User: Identifiable, Codable {
    
    var id: String {documentId}
    
    let documentId: String
    let uid, name, email, profileImageUrl, profileText: String
    let joinDate: Date
    
    init(documentId: String, data: [String:Any]) {
        self.documentId = documentId
        self.uid = data["uid"] as? String ?? "no"
        self.email = data["email"] as? String ?? "no email"
        self.name = data["name"] as? String ?? "no name"
        self.profileImageUrl = data["profileImageUrl"] as? String ?? "no profileImageUrl"
        self.profileText = data["profileText"] as? String ?? "no profileText"
        self.joinDate = data["joinDate"] as? Date ?? Date()
    }
    
    
}


struct Post: Identifiable, Codable {
    
    var id : String { documentId }
    
    let documentId: String
    let authorUid, postText : String
    let authorName, authorEmail, authorProfileUrl : String
    let postImageUrl: String
    let time: Timestamp
    var likes: Int
    
    var didLike: Bool? = false
    
    init(documentId: String, data: [String:Any] ) {
        self.documentId = documentId
        self.authorUid = data["authorUid"] as? String ?? "no authorUid"
        self.authorEmail = data["authorEmail"] as? String ?? "no authorEmail"
        self.authorName = data["authorName"] as? String ?? "no authorName"
        self.authorProfileUrl = data["authorProfileUrl"] as? String ?? "no authorProfileUrl"
        self.postText = data["postText"] as? String ?? "no postText"
        self.postImageUrl = data["postImageUrl"] as? String ?? "no postImageUrl"
        
        self.time = data["time"] as? Timestamp ?? Timestamp()
        self.likes = data["likes"] as? Int ?? 0
    }
}
