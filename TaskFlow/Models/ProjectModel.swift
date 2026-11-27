//
//  ProjectModel.swift
//  TaskFlow
//
//  Created by Julio Garcìa on 25/11/26.
//

import Foundation
import FirebaseFirestoreSwift

struct ProjectModel: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var ownerId: String
    var memberIds: [String]
}
