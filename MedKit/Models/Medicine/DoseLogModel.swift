//
//  DoseLogModel.swift
//  MedKit
//
//  Created by Rishik Dev on 04/10/26.
//

import Foundation

struct DoseLogModel: Identifiable, Equatable, Hashable {
    let id: UUID
    var date: Date
    var isTaken: Bool
    var takenByUserName: String?
    
    init(id: UUID = UUID(), date: Date, isTaken: Bool = false, takenByUserName: String? = nil) {
        self.id = id
        self.date = date
        self.isTaken = isTaken
        self.takenByUserName = takenByUserName
    }
    
    public static func fromEntity(_ entity: DoseLogEntity) -> DoseLogModel? {
        guard let id = entity.id, let date = entity.date else { return nil }
        return DoseLogModel(
            id: id,
            date: date,
            isTaken: entity.isTaken,
            takenByUserName: entity.takenByUserName
        )
    }
}
