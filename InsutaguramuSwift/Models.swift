//
//  Models.swift
//  InsutaguramuSwift
//
//  Created by 小暮準才 on 2022/07/31.
//

import Foundation
import FirebaseFirestoreSwift


struct User: Identifiable {
    
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
